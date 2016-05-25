/**
 * TASM - TPU ASseMbler
 * 
 * One source file assembler for TPU. Incredibly basic and has lots of assumptions. 
 * Built quickly to get something running, not reliable. ;)
 *
 * Issues:
 *   Error checking is very lax. Some immediate forms are bounds checked, but that is all
 *   The parser isn't real, does not check token types and gets confused easily
 *   Comments (preceeding #) can confuse some instructions, perticularly dw
 *   No support for outputting multiple BRAM initializers
 *   Assebled output alwways starts at address 0x0000
 *
 * Labels:  
 *    my_label_here:              - defines the label location
 *   $my_label_here               - absolute (unsigned) value of label location
 *   %my_label_here               - relative (signed) value of label location
 * 
 * Basic dataflow:
 *  1) split strings by line 
 *  2) discover labels and associate with line/address
 *  3) swap labels with constant addresses
 *  4) parse instructions
 *  5) write out bit stream of instruction
 *  
 * You can introduce new mnemonics by modifying entries in initOpMap().
 */

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;

namespace tasm
{
    class tasm_main
    {
        enum OpCodes
        {
            OpAdd = 0,
            OpSub = 1,
            OpOr = 2,
            OpXor= 3,
            OpAnd = 4,
            OpNot = 5,
            OpRead = 6,
            OpWrite = 7,
            OpLoad = 8,
            OpCmp = 9,
            OpShl = 10,
            OpShr = 11,
            OpBranch = 12,
            OpCondBranch = 13,
            OpSpecial = 14,
            OpMul = 15
        }

        enum BranchCondition
        {
            EQ = 0,
            AZ = 1,
            BZ = 2,
            ANZ = 3,
            BNZ = 4,
            AGB = 5,
            ALB = 6
        }

        enum SpecialAssign
        {
            SAVE_PC = 0,
            SAVE_STATUS = 1,
            GIEF = 2,
            BBI = 3,
            EI = 4,
            DI = 5,
            INT = 6,
        }

        struct OpData
        {
            public UInt16 opcode;
            public UInt16 rD;
            public UInt16 rA;
            public UInt16 rB;
            public UInt16 signedness;
            public UInt16 flags;
            public Int16  sval;
            public OpGenerator gen;
        }

        abstract class OutGenerator
        {
            public abstract void GenerateOutput(string filename, List<OpData> ops);
        }

        abstract class OpGenerator
        {
            public abstract UInt16 BuildInstruction(OpData data);

            public void BinStream(OpData data, BinaryWriter sw)
            {
                UInt16 inst = BuildInstruction(data);
                byte[] bytes = BitConverter.GetBytes(inst);
                sw.Write(bytes);
            }

            public void EramStream(OpData data, StreamWriter sw)
            {
                UInt16 inst = BuildInstruction(data);
                byte high = (byte)(inst >> 8);
                byte low = (byte)(inst & 0xFF);
                sw.Write(String.Format("X\"{0:X2}\", X\"{1:X2}\"", high, low));
            }

            public void HexStream(OpData data, StreamWriter sw)
            {
                UInt16 inst = BuildInstruction(data);
                sw.Write(String.Format("{0:X4}", inst));
            }

            public void BinTxtStream(OpData data, StreamWriter sw)
            {
                UInt16 inst = BuildInstruction(data);
                sw.Write(Convert.ToString(inst, 2).PadLeft(16, '0'));
            }
        }

        class OpGeneratorRRR : OpGenerator
        {
            public override UInt16 BuildInstruction(OpData data)
            {
                UInt16 inst = 0;

                inst |= (UInt16)((data.opcode & (UInt16)0xF) << (UInt16)12);
                inst |= (UInt16)((data.rD & (UInt16)0x7) << (UInt16)9);
                inst |= (UInt16)((data.signedness & (UInt16)0x1) << (UInt16)8);
                inst |= (UInt16)((data.rA & (UInt16)0x7) << (UInt16)5);
                inst |= (UInt16)((data.rB & (UInt16)0x7) << (UInt16)2);
                inst |= (UInt16)((data.flags & (UInt16)0x3));
                return inst;
            }
        }

        class OpGeneratorRRImm : OpGenerator
        {
            public override UInt16 BuildInstruction(OpData data)
            {
                UInt16 inst = 0;

                inst |= (UInt16)((data.opcode & (UInt16)0xF) << (UInt16)12);
                inst |= (UInt16)((data.rD & (UInt16)0x7) << (UInt16)9);
                inst |= (UInt16)((data.signedness & (UInt16)0x1) << (UInt16)8);
                inst |= (UInt16)((data.rA & (UInt16)0x7) << (UInt16)5);
                inst |= (UInt16)((data.rB & (UInt16)0xf) << (UInt16)1);
                inst |= (UInt16)(data.flags & (UInt16)0x01);

                return inst;
            }
        }

        class OpGeneratorCRsI : OpGenerator
        {
            public override UInt16 BuildInstruction(OpData data)
            {
                UInt16 inst = 0;

                inst |= (UInt16)((data.opcode & (UInt16)0xF) << (UInt16)12);
                inst |= (UInt16)((data.rD & (UInt16)0x7) << (UInt16)9);
                inst |= (UInt16)((data.signedness & (UInt16)0x1) << (UInt16)8);
                inst |= (UInt16)((data.rA & (UInt16)0x7) << (UInt16)5);
                inst |= (UInt16)((data.sval & (Int16)0x1f));

                return inst;
            }
        }

        class OpGeneratorRI : OpGenerator
        {
            public override UInt16 BuildInstruction(OpData data)
            {
                UInt16 inst = 0;

                inst |= (UInt16)((data.opcode & (UInt16)0xF) << (UInt16)12);
                inst |= (UInt16)((data.rD & (UInt16)0x7) << (UInt16)9);
                inst |= (UInt16)((data.signedness & (UInt16)0x1) << (UInt16)8);
                inst |= (UInt16)((data.rA & (UInt16)0xFF));

                return inst;
            }

        }

        class OpGeneratorRsI : OpGenerator
        {
            public override UInt16 BuildInstruction(OpData data)
            {
                UInt16 inst = 0;

                inst |= (UInt16)((data.opcode & (UInt16)0xF) << (UInt16)12);
                inst |= (UInt16)((data.rD & (UInt16)0x7) << (UInt16)9);
                inst |= (UInt16)((data.signedness & (UInt16)0x1) << (UInt16)8);
                inst |= (UInt16)((data.sval & (UInt16)0xFF));

                return inst;
            }

        }

        // uses rD as additional immediate, and truncates last bit.
        // used for brach targets
        class OpGeneratorRIExt : OpGenerator
        {
            public override UInt16 BuildInstruction(OpData data)
            {
                UInt16 inst = 0;

                inst |= (UInt16)((data.opcode & (UInt16)0xF) << (UInt16)12);

                inst |= (UInt16)((data.rA & (UInt16)0x0E00));

                inst |= (UInt16)((data.signedness & (UInt16)0x1) << (UInt16)8);
                inst |= (UInt16)(((data.rA >> 1) & (UInt16)0xFF));

                return inst;
            }

        }


        //Same Signed intermediate, shifted right once (for branch targets)
        class OpGeneratorRSignedIExt : OpGenerator
        {
            public override UInt16 BuildInstruction(OpData data)
            {
                UInt16 inst = 0;

                inst |= (UInt16)((data.opcode & (UInt16)0xF) << (UInt16)12);

                inst |= (UInt16)((data.sval & (UInt16)0x0E00));

                inst |= (UInt16)((data.signedness & (UInt16)0x1) << (UInt16)8);
                inst |= (UInt16)(((data.sval >> 1) & (UInt16)0xFF));

                return inst;
            }

        }

        class OpGeneratorDataD : OpGenerator
        {
            public override UInt16 BuildInstruction(OpData data)
            {
                return data.rD;
            }

        }

        abstract class OpCodeParser
        {
            public abstract OpData Parse(string[] args);

            public OpData ParseAndIncUsage(string[] args)
            {
                m_useCount++;
                return Parse(args);
            }

            public uint Usages { get { return m_useCount; } }

            protected string trimReg(string a)
            {
                if (a.ElementAt(0) == 'r')
                {
                    a = a.Substring(1);
                }
                if (a.Length > 1)
                {
                    if (a.ElementAt(1) == ',')
                    {
                        a = "" + a.ElementAt(0);
                    }
                }
                return a;
            }

            private uint m_useCount = 0;
        }

        class OpCodeParserI : OpCodeParser
        {
            public override OpData Parse(string[] args)
            {
                string im = trimReg(args[1]);

                OpData data = new OpData();
                data.rD = 0;
                if (im.StartsWith("0x"))
                {
                    string hex = im.Substring(2);
                    data.rA = ushort.Parse(hex, System.Globalization.NumberStyles.HexNumber);
                }
                else
                {
                    data.rA = ushort.Parse(im);
                }

                if ((data.rA & 1) == 1)
                {
                    Console.Error.WriteLine("Line " + lineNum + ": bi can only jump to 2 byte boundaries ");
                    Environment.Exit(3);
                }
                if ((data.rA & 0xF000) != 0)
                {
                    Console.Error.WriteLine("Line " + lineNum + ": bi branch target out of range ");
                    Environment.Exit(3);
                }
                
                data.flags = 0;
                data.gen = new OpGeneratorRIExt();
                return data;
            }
        };

        class OpCodeParserSignedI : OpCodeParser
        {
            public override OpData Parse(string[] args)
            {
                string im = trimReg(args[1]);

                OpData data = new OpData();
                data.rD = 0;
                if (im.StartsWith("0x"))
                {
                    string hex = im.Substring(2);
                    data.sval = short.Parse(hex, System.Globalization.NumberStyles.HexNumber);
                }
                else
                {
                    data.sval = short.Parse(im);
                }

                if ((data.sval & 1) == 1)
                {
                    Console.Error.WriteLine("Line " + lineNum + ": biro can only jump to 2 byte boundaries ");
                    Environment.Exit(3);
                }
                if ((data.sval >= 2048) || (data.sval < -2048))
                {
                    Console.Error.WriteLine("Line " + lineNum + ": biro branch target out of range ");
                    Environment.Exit(3);
                }

                data.flags = 0;
                data.gen = new OpGeneratorRSignedIExt();
                return data;
            }
        };
        class OpCodeParserRs : OpCodeParser
        {
            public override OpData Parse(string[] args)
            {
                string rA = trimReg(args[1]);

                OpData data = new OpData();
                data.rD = 0;
                data.rA = ushort.Parse(rA);
                data.rB = 0;
                data.flags = 0;
                data.gen = new OpGeneratorRRR();
                return data;
            }
        };
        class OpCodeParserRd : OpCodeParser
        {
            public override OpData Parse(string[] args)
            {
                string rD = trimReg(args[1]);

                OpData data = new OpData();
                data.rD = ushort.Parse(rD);
                data.rA = 0;
                data.rB = 0;
                data.flags = 0;
                data.gen = new OpGeneratorRRR();
                return data;
            }
        };

        class OpCodeParserRI : OpCodeParser
        {
            public override OpData Parse(string[] args)
            {
                string rd = trimReg(args[1]);
                string im = trimReg(args[2]);

                OpData data = new OpData();
                data.rD = ushort.Parse(rd);

                if (im.StartsWith("0x"))
                {
                    string hex = im.Substring(2);
                    data.rA = ushort.Parse(hex, System.Globalization.NumberStyles.HexNumber);
                }
                else
                {
                    data.rA = ushort.Parse(im);
                }
                data.flags = 0;
                data.gen = new OpGeneratorRI();
                return data;
            }
        };

        class OpCodeParserRRR: OpCodeParser
        {
            public override OpData Parse(string[] args)
            {
                string rd = trimReg(args[1]);
                string ra = trimReg(args[2]);
                string rb = trimReg(args[3]);

                OpData data = new OpData();
                data.rD = ushort.Parse(rd);
                data.rA = ushort.Parse(ra);
                data.rB = ushort.Parse(rb);
                data.flags = 0;
                data.gen = new OpGeneratorRRR();
                return data;
            }
        };

        class GenData : OpCodeParser
        {
            public override OpData Parse(string[] args)
            {
                string datavalue = args[1];

                OpData data = new OpData();

                if (datavalue.StartsWith("0x"))
                {
                    string hex = datavalue.Substring(2);
                    data.rD = ushort.Parse(hex, System.Globalization.NumberStyles.HexNumber);
                }
                else if (datavalue.StartsWith("\""))
                {
                    bool found = false;
                    datavalue = Regex.Unescape(datavalue);
                    // check if datavalue has opening and closing quotes
                    if (datavalue.StartsWith("\"") && datavalue.EndsWith("\""))
                    {
                        found = true;
                    }
                    // check if there are more args with the end data.
                    else if (args.Length > 2)
                    {
                        int idx = 2;
                        do {    
                            datavalue += " " + args[2];
                        } while (!(datavalue.StartsWith("\"") && datavalue.EndsWith("\""))
                            && idx < args.Length);

                        found = datavalue.StartsWith("\"") && datavalue.EndsWith("\"");
                    }

                    if (found)
                    {
                        datavalue = datavalue.Substring(1, datavalue.Length - 2) ;
                        byte[] b = System.Text.Encoding.ASCII.GetBytes(datavalue);
                        if (b.Length > 2)
                        {
                            Console.Error.WriteLine("Line " + lineNum + ": Maximum of two characters per dw - " + datavalue);
                            Environment.Exit(3);
                        }
                        else if (b.Length == 2)
                        {
                            data.rD = (ushort)((((uint)b[0]) << 8) | b[1] & 0xFFU);
                        }
                        else
                        {
                            data.rD = (ushort)((((uint)b[0]) << 8) & 0xFF00U);
                        }
                    }
                    else
                    {
                         Console.Error.WriteLine("Line " + lineNum + ": Couldn't parse string - " + datavalue);
                         Environment.Exit(3);
                    }
                }
                else
                {
                    data.rD = ushort.Parse(datavalue);
                }
                data.gen = new OpGeneratorDataD();
                return data;
            }
        };

        class OpCodeParserRR : OpCodeParser
        {
            public override OpData Parse(string[] args)
            {
                string rd = trimReg(args[1]);
                string ra = trimReg(args[2]);

                OpData data = new OpData();
                data.rD = ushort.Parse(rd);
                data.rA = ushort.Parse(ra);
                data.rB = 0;
                data.flags = 0;
                data.gen = new OpGeneratorRRR();//RRR is ok for RR form
                return data;
            }
        };

        class OpCodeParserRRImm : OpCodeParser
        {
            public override OpData Parse(string[] args)
            {
                string rd = trimReg(args[1]);
                string ra = trimReg(args[2]);

                string os = "0";
                if (args.Length >= 4)
                {
                    os = trimReg(args[3]);
                }
                short val;
                OpData data = new OpData();
                data.rD = ushort.Parse(rd);
                data.rA = ushort.Parse(ra);
                data.rB = 0;
                data.sval = short.TryParse(os, out val)?val:(short)0;
                data.flags = 0;
                data.gen = new OpGeneratorCRsI();
                return data;
            }
        };

        class OpCodeParserRSI : OpCodeParser
        {
            public override OpData Parse(string[] args)
            {
                string rd = trimReg(args[1]);
                string ra = trimReg(args[2]);

                OpData data = new OpData();
                data.rD = ushort.Parse(rd);
                data.sval = short.Parse(ra);
                data.rB = 0;
                data.flags = 0;
                data.gen = new OpGeneratorRRR();//RRR is ok for RR form
                return data;
            }
        };

        class GenAdd : OpCodeParserRRR
        {
            public GenAdd(bool _signed = false)
            {
                signed = _signed;
            }
            public override OpData Parse(string[] args)
            {
                if (args.Length < 4)
                {
                    Console.Error.WriteLine("Line " + lineNum + ": Not enough arguments for instruction " + args[0]);
                    Environment.Exit(3);
                }
                OpData data = base.Parse(args);

                if (!args[3].StartsWith("r"))
                {
                    Console.Out.WriteLine("Line " + lineNum + ": Argument 3 of instruction " + args[0] + " is not a register. Do you mean to use addi?");
                }
                
                data.opcode = (UInt16)OpCodes.OpAdd;
                data.signedness = (UInt16)((signed)?1:0);
                return data;
            }
            bool signed;
        };

        class GenAddI : OpCodeParserRRR
        {
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                data.opcode = (UInt16)OpCodes.OpAdd;
                data.signedness = 0;
                data.flags = 1;
                data.gen = new OpGeneratorRRImm();
                return data;
            }
        };

        class GenSub : OpCodeParserRRR
        {
            public GenSub(bool _signed = false)
            {
                signed = _signed;
            }
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);
                
                data.opcode = (UInt16)OpCodes.OpSub;
                data.signedness = (UInt16)((signed)?1:0);
                return data;
            }
            bool signed;
        };

        class GenSubI : OpCodeParserRRR
        {
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                data.opcode = (UInt16)OpCodes.OpSub;
                data.signedness = 0;
                data.flags = 1;
                data.gen = new OpGeneratorRRImm();
                return data;
            }
        };
        class GenOr : OpCodeParserRRR
        {
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                data.opcode = (UInt16)OpCodes.OpOr;
                data.signedness = 0;
                return data;
            }
        };

        class GenXor : OpCodeParserRRR
        {
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                data.opcode = (UInt16)OpCodes.OpXor;
                data.signedness = 0;
                return data;
            }
        };

        class GenShift : OpCodeParserRRR
        {
            UInt16 opcode_shift_type = (UInt16)OpCodes.OpShr;
            public GenShift(bool left)
            {
                if (left)
                {
                    opcode_shift_type = (UInt16)OpCodes.OpShl;
                }
                else
                {
                    opcode_shift_type = (UInt16)OpCodes.OpShr;
                }
            }
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                data.opcode = opcode_shift_type;
                data.signedness = 0;
                return data;
            }
        };

        class GenAnd : OpCodeParserRRR
        {
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                data.opcode = (UInt16)OpCodes.OpAnd;
                data.signedness = 0;
                return data;
            }
        };

        class GenNot : OpCodeParserRR
        {
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                data.opcode = (UInt16)OpCodes.OpNot;
                data.signedness = 0;
                return data;
            }
        };

        class GenRead : OpCodeParserRRImm
        {
            public GenRead(bool byteOnly = false)
            {
                byteOp = byteOnly;
            }
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                data.opcode = (UInt16)OpCodes.OpRead;
                data.signedness = (UInt16)((byteOp) ? 1 : 0);
                return data;
            }
            public bool byteOp;
        }

        class GenWrite : OpCodeParserRRImm
        {
            public GenWrite(bool byteOnly = false)
            {
                byteOp = byteOnly;
            }

            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                data.rB = data.rA;
                data.rA = data.rD;
                data.rD = (UInt16)(data.sval >> 2);
                data.flags = (UInt16)(data.sval & 0x3);
                data.opcode = (UInt16)OpCodes.OpWrite;
                data.signedness = (UInt16)((byteOp)?1:0);
                // as we've split sval already above we use RRR
                data.gen = new OpGeneratorRRR();
                return data;
            }

            public bool byteOp;
        }
        
        class GenLoad : OpCodeParserRI
        {
            public GenLoad(bool low)
            {
                m_low = low;
            }
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                data.opcode = (UInt16)OpCodes.OpLoad;
                data.signedness = (UInt16)(m_low ? 1 : 0);
                return data;
            }
            bool m_low;
        };

        class GenJmpImm : OpCodeParserSignedI
        {
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                data.opcode = (UInt16)OpCodes.OpBranch;
                data.signedness = 1;
                return data;
            }
        };
        class GenJmpReg : OpCodeParserRs
        {   
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                data.opcode = (UInt16)OpCodes.OpBranch;
                data.signedness = 0;
                return data;
            }
        };

        class GenCmp : OpCodeParserRRR
        {
            public GenCmp(bool signed)
            {
                m_signed = signed;
            }
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                data.opcode = (UInt16)OpCodes.OpCmp;
                data.signedness = (UInt16)(m_signed ? 1 : 0);
                return data;
            }
            bool m_signed;
        };

        class GenCndJmp : OpCodeParserRR
        {
            public GenCndJmp(BranchCondition cond)
            {
                m_cond = cond;
            }
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                data.rB = data.rA;
                data.rA = data.rD;
                data.rD = (UInt16)m_cond;
                data.opcode = (UInt16)OpCodes.OpCondBranch;
                data.signedness = 0;
                data.gen = new OpGeneratorRRR();
                return data;
            }
            BranchCondition m_cond;

        };

        class GenCndJmpRO : OpCodeParserRSI
        {
            public GenCndJmpRO(BranchCondition cond)
            {
                m_cond = cond;
            }
            public override OpData Parse(string[] args)
            {
                OpData data = base.Parse(args);

                if ((data.sval > 15)
                    || (data.sval < -16))
                {
                    Console.Error.WriteLine("Constant relative offset is out of range [-16, 15]: "+data.sval);
                    Console.Error.WriteLine("Whilst parsing: " + string.Join(" ", args));
                    Environment.Exit(2);
                }

                data.rA = data.rD;
                data.rD = (UInt16)m_cond;
                data.opcode = (UInt16)OpCodes.OpCondBranch;
                data.signedness = 1;
                data.gen = new OpGeneratorCRsI();
                return data;
            }
            BranchCondition m_cond;

        };

        class GenSpecialAssign : OpCodeParserRd {
            public GenSpecialAssign(SpecialAssign _sp)
            {
                sp = _sp;
            }
            public override OpData Parse(string[] args)
            {
                OpData data = new OpData();
                data.gen = null;
                switch (sp)
                {
                    case SpecialAssign.INT:
                        {
                            data.rD = 0;
                            data.rA = 0;
                            data.rB = 0;
                            data.flags = (UInt16)0x02;
                            data.signedness = 0;

                            string im = trimReg(args[1]);
                            if (im.StartsWith("0x"))
                            {
                                string hex = im.Substring(2);
                                data.rA = ushort.Parse(hex, System.Globalization.NumberStyles.HexNumber);
                            }
                            else
                            {
                                data.rA = ushort.Parse(im);
                            }
                            // shift the immediate twice left, then or the flags
                            data.rA = (ushort)(data.rA << 2);
                            data.rA = (ushort)(data.rA | data.flags);
                            data.gen = new OpGeneratorRI();
                            break;
                        }
                    case SpecialAssign.SAVE_PC:
                        data = base.Parse(args);
                        data.flags = (UInt16)0x00;
                        data.signedness = 0;
                        break;

                    case SpecialAssign.SAVE_STATUS:
                        data = base.Parse(args);
                        data.flags = (UInt16)0x01;
                        data.signedness = 0;
                        break;

                    case SpecialAssign.GIEF:
                        data = base.Parse(args);
                        data.rA = 0;
                        data.rB = 0;
                        data.flags = (UInt16)0x00;
                        data.signedness = 1;
                        break;

                    case SpecialAssign.BBI:
                        data.rD = 0;
                        data.rA = 0;
                        data.rB = 0;
                        data.flags = (UInt16)0x01;
                        data.signedness = 1;
                        break;

                    case SpecialAssign.EI:
                        data.rD = 0;
                        data.rA = 0;
                        data.rB = 0;
                        data.flags = (UInt16)0x02;
                        data.signedness = 1;
                        break;

                    case SpecialAssign.DI:
                        data.rD = 0;
                        data.rA = 0;
                        data.rB = 0;
                        data.flags = (UInt16)0x03;
                        data.signedness = 1;
                        break;
                }


                data.opcode = (UInt16)OpCodes.OpSpecial;
                if (data.gen == null)
                {
                    data.gen = new OpGeneratorRRR();
                }
                return data;
            }
            SpecialAssign sp;
        };

        static List<OpData> ops;
        static List<string[]> inputs;
        static List<int> inputlines;
        static Dictionary<string, OpCodeParser> opmap;
        static Dictionary<string, OutGenerator> outmap;
        static Dictionary<string, UInt16> labels;
        static int lineNum = 0;
        static string filename = "<unknown>";
        
        static void linkLabels(string[] things, int PC = 0)
        {
            for(int i = 0; i < things.Length; i++)
            {
                string t=things[i].Trim();
                if (t.Length == 0)
                    continue;

                //absolute
                if (t.ElementAt(0)=='$')
                {
                    bool high = false;
                    bool low = false;
                    t = t.Substring(1);
                    //check if label ends with .h or .l
                    if (t.EndsWith(".h"))
                    {
                        high = true;
                       t= t.Remove(t.Length - 2);
                    } 
                    else if (t.EndsWith(".l"))
                    {
                        low = true;
                       t= t.Remove(t.Length - 2);
                    }
                    if (!labels.ContainsKey(t))
                    {
                        //label undefined
                        Console.Error.WriteLine(filename + ":" + lineNum + "- Error: Label \"" + t + "\" undefined.");
                    }
                    else
                    {
                        if (high)
                        {
                            things[i] = String.Format("0x{0:x4}", (labels[t] & 0xFF00) >> 8);
                        }
                        else if (low)
                        {
                            things[i] = String.Format("0x{0:x4}", labels[t]&0xFF);
                        }
                        else
                        {
                            things[i] = String.Format("0x{0:x4}", labels[t]);
                        }
                    }
                }

                //relative
                if (t.ElementAt(0) == '%')
                {
                    t = t.Substring(1);
                    if (!labels.ContainsKey(t))
                    {
                        //label undefined
                        Console.Error.WriteLine(filename + ":" + lineNum + "- Error: Label \"" + t + "\" undefined.");
                    }
                    else
                    {
                        things[i] = String.Format("{0:d}", labels[t] - PC);
                    }
                }
            }
        }

        static void initOpMap()
        {
            opmap = new Dictionary<string, OpCodeParser>();
            //deprecated opmap["add"] = new GenAdd();
            //deprecated opmap["sub"] = new GenSub();
            opmap["add.u"] = new GenAdd(false);
            opmap["sub.u"] = new GenSub(false);
            opmap["add.s"] = new GenAdd(true);
            opmap["sub.s"] = new GenSub(true);
            opmap["addi"] = new GenAddI();
            opmap["subi"] = new GenSubI();
            //deprecated opmap["addi.u"] = new GenAddI();
            //deprecated opmap["subi.u"] = new GenSubI();
            opmap["or"] = new GenOr();
            opmap["and"] = new GenAnd();
            opmap["xor"] = new GenXor();
            opmap["not"] = new GenNot();
            opmap["sl"] = new GenShift(true);
            opmap["sr"] = new GenShift(false);
            opmap["shl"] = new GenShift(true);
            opmap["shr"] = new GenShift(false);
            opmap["load.l"] = new GenLoad(true);
            opmap["load.h"] = new GenLoad(false);
            opmap["cmp.u"] = new GenCmp(false);
            opmap["cmp.s"] = new GenCmp(true);
            opmap["biro"] = new GenJmpImm();
            opmap["br"] = new GenJmpReg();
            opmap["br.eq"] = new GenCndJmp(BranchCondition.EQ);
            opmap["br.az"] = new GenCndJmp(BranchCondition.AZ);
            opmap["br.bz"] = new GenCndJmp(BranchCondition.BZ);
            opmap["br.anz"] = new GenCndJmp(BranchCondition.ANZ);
            opmap["br.bnz"] = new GenCndJmp(BranchCondition.BNZ);
            opmap["br.lt"] = new GenCndJmp(BranchCondition.ALB);
            opmap["br.gt"] = new GenCndJmp(BranchCondition.AGB);
            opmap["bro.eq"] = new GenCndJmpRO(BranchCondition.EQ);
            opmap["bro.az"] = new GenCndJmpRO(BranchCondition.AZ);
            opmap["bro.bz"] = new GenCndJmpRO(BranchCondition.BZ);
            opmap["bro.anz"] = new GenCndJmpRO(BranchCondition.ANZ);
            opmap["bro.bnz"] = new GenCndJmpRO(BranchCondition.BNZ);
            opmap["bro.lt"] = new GenCndJmpRO(BranchCondition.ALB);
            opmap["bro.gt"] = new GenCndJmpRO(BranchCondition.AGB);
            //deprecated opmap["read"] = new GenRead();
            //deprecated opmap["write"] = new GenWrite();
            opmap["read.w"] = new GenRead();
            opmap["write.w"] = new GenWrite();
            opmap["read.b"] = new GenRead(true);
            opmap["write.b"] = new GenWrite(true);
            opmap["dw"] = new GenData();
            opmap["spc"] = new GenSpecialAssign(SpecialAssign.SAVE_PC);
            opmap["sstatus"] = new GenSpecialAssign(SpecialAssign.SAVE_STATUS);
            opmap["gief"] = new GenSpecialAssign(SpecialAssign.GIEF);
            opmap["bbi"] = new GenSpecialAssign(SpecialAssign.BBI);
            opmap["ei"] = new GenSpecialAssign(SpecialAssign.EI);
            opmap["di"] = new GenSpecialAssign(SpecialAssign.DI);
            opmap["int"] = new GenSpecialAssign(SpecialAssign.INT);
            //deprecated opmap["data"] = new GenData();
        }

        static void initOutFormats()
        {
            outmap = new Dictionary<string, OutGenerator>();
            outmap["bin"] = new OutGenBin();
            outmap["hex"] = new OutGenHex();
            outmap["eram"] = new OutGenERAM();
            outmap["bram"] = new OutGenBRAM();
        }


        class OutGenHex : OutGenerator
        {
            public override void GenerateOutput(string filename, List<OpData> ops)
            {
                StreamWriter sw = new StreamWriter(filename);
                foreach (OpData op in ops)
                {
                    sw.Write("0x");
                    op.gen.HexStream(op, sw);
                    sw.Write(",");
                    sw.Write(sw.NewLine);
                }
                sw.Close();
            }
        }

        class OutGenBin : OutGenerator
        {
            public override void GenerateOutput(string filename, List<OpData> ops)
            {
                BinaryWriter bw = new BinaryWriter(new FileStream(filename, FileMode.Create));
                foreach (OpData op in ops)
                {
                    op.gen.BinStream(op, bw);
                }
                bw.Close();
            }
        }

        class OutGenERAM : OutGenerator
        {
            string FormatInstruction(string[] instruction)
            {
                if (instruction.Length == 1)
                {
                    return instruction[0];
                }
                //Pad the instruction
                //Lets not ever mention what's happening below.
                List<string> insts = instruction.ToList();
                StringBuilder sb = new StringBuilder();
                insts.RemoveAt(0);
                sb.Append(instruction[0].PadRight(8));
                sb.Append(string.Join(" ", insts));
                return sb.ToString();
            }

            public override void GenerateOutput(string filename, List<OpData> ops)
            {
                StreamWriter sw = new StreamWriter(filename);
                int inst = 0;
                foreach (OpData op in ops)
                {
                    op.gen.EramStream(op, sw);
                    sw.Write(", -- " + String.Format("{0:X4}: ", inst*2) + FormatInstruction(inputs[inst]));
                    sw.Write(sw.NewLine);
                    inst ++;
                }

                
                for (int i = (inst*2); i < eram_size_forced; i+=2)
                {
                    sw.Write("X\"00\", X\"00\", -- " + String.Format("{0:X4}: ", i) + "PAD" );
                    sw.Write(sw.NewLine);
                }
                

                Console.WriteLine("Instruction stream consists of " + (inst * 2) + " bytes.");
                sw.Close();
            }
        }

        class OutGenBRAM : OutGenerator
        {
            string FormatInstruction(string[] instruction)
            {
                if (instruction.Length == 1)
                {
                    return instruction[0];
                }

                //Lets not ever mention what's happening below.
                List<string> insts = instruction.ToList();
                StringBuilder sb = new StringBuilder();
                insts.RemoveAt(0);
                sb.Append(instruction[0].PadRight(8));
                sb.Append(string.Join(" ", insts));
                return sb.ToString();
            }

            public override void GenerateOutput(string filename, List<OpData> ops)
            {
                StreamWriter sw = new StreamWriter(filename);
                int instnum = 0;
                int linecount = 0;
                int init_lines = 0;
                string lineofinsts = "";
                sw.WriteLine("-- BEGIN TASM RAMB16BWER INIT OUTPUT");
                foreach (OpData op in ops)
                {
                    if (linecount ==0 )
                    {
                        sw.Write("INIT_" + String.Format("{0:X2}", init_lines) + " => X\"");
                    }
                    UInt16 data = op.gen.BuildInstruction(op);

                    // we need to flip the 2 bytes.
                    UInt16 t = (UInt16)(data & (UInt16)0x00ff);
                    data = (UInt16)(data >> 8);
                    data |= (UInt16)(t << 8);

                    
                    lineofinsts = String.Format("{0:X4}", data) + lineofinsts;
                    instnum++;
                    linecount++;
                    if (linecount == 16 )
                    {
                        init_lines++;
                        if (init_lines > 63)
                        {
                            Console.Error.WriteLine("WARNING: Output exceeds size of 18Kb Xilinx BRAM");
                        }
                        sw.Write(lineofinsts);
                        sw.WriteLine("\",");
                        linecount = 0;
                        lineofinsts = "";
                    }
                }

                // output can finish mid-INIT line.
                // This picks up where we left off to complete.
                while (init_lines <= 63)
                {
                    if (linecount == 0)
                    {
                        sw.Write("INIT_" + String.Format("{0:X2}", init_lines) + " => X\"");
                    }
                    lineofinsts = "0000" + lineofinsts;
                    linecount++;
                    if (linecount == 16)
                    {
                        init_lines++;
                        sw.Write(lineofinsts);
                        sw.WriteLine("\",");
                        linecount = 0;
                        lineofinsts = "";
                    }
                }


                sw.WriteLine("-- END TASM RAMB16BWER INIT OUTPUT");

                Console.WriteLine("Instruction stream consists of " + (instnum * 2) + " bytes.");
                sw.Close();
            }
        }



        static int VERSION_MAJOR = 1;
        static int VERSION_MINOR = 5;

        static bool debug_output = false;
        static int eram_size_forced = -1;

        static int Main(string[] args)
        {
            ops = new List<OpData>();
            labels = new Dictionary<string, UInt16>();
            inputs = new List<string[]>();
            inputlines = new List<int>();

            initOutFormats();
            initOpMap();
            string line;

            if (args.Length == 0 || args[0].EndsWith("-help"))
            {
                Console.WriteLine("TPU Assembler Version " + VERSION_MAJOR + "." + VERSION_MINOR);
                Console.WriteLine();
                Console.WriteLine("Usage: tasm <inputfile> <outputfile>.<ext> -p <num> -v");
                Console.WriteLine();
                Console.WriteLine("    -p <num>");
                Console.WriteLine("\tForce the output size to <num> bytes by adding padding.");
                Console.WriteLine("    -v");
                Console.WriteLine("\tPrint verbose output. Must be last option.");
                Console.WriteLine("    outputfile.ext ");
                Console.WriteLine("\tThe extension defines the output format. Supported formats:");
                foreach(KeyValuePair<string, OutGenerator> keyval in outmap)
                {
                    Console.WriteLine("\t\t" + keyval.Key);
                }
                return 1;
            }

            filename = args[0];

            StreamReader file = null;

            try
            {
                file = new StreamReader(filename);
            }
            catch (Exception e)
            {
                Console.Error.WriteLine("Error reading file \"" + filename + "\":");
                Console.Error.WriteLine(e.Message);
                return 2;
            }

            string outfile = "out.hex";
            if (args.Length > 1)
            {
                outfile = args[1];
            }

            if (args.Length > 3)
            {
                if (args[2] == "-p" )
                {
                    eram_size_forced = int.Parse(args[3]);
                }
                if (args.Length > 4)
                {
                    debug_output = (args[4] == "-v");
                }
            }
            else if (args.Length > 2)
            {
                debug_output = (args[2] == "-v");
            }


            int instructionOffset = 0;
            lineNum = 0;

            // read line asm data
            while ((line = file.ReadLine()) != null)
            {
                lineNum++;
                line = line.Trim();
                if(line.StartsWith("#") || line.Length==0)
                {
                    continue;
                }

                string[] bittys = line.Split(new Char [] {' ', '\t', ','});

                //strip empty strings
                List<string> bittypacked = new List<string>();
                for (uint i = 0; i < bittys.Length; i++)
                {
                    if (bittys[i] != "")
                    {
                        bittypacked.Add(bittys[i]);
                    }
                }
                bittys = bittypacked.ToArray();

                //check if this is a label
                if(bittys[0].Last() == ':')
                {
                    string labelname = bittys[0].Substring(0, bittys[0].Length - 1);
                    UInt16 labeladdr = (UInt16)instructionOffset;

                    if (labels.ContainsKey(labelname))
                    {
                        //label redefined
                        Console.Error.WriteLine(filename + ":" + lineNum + "- Error: Label \"" + labelname + "\" redefined.");
                    }
                    else
                    {
                        labels[labelname] = labeladdr;
                    }
                    
                    if (bittys.Length < 2)
                    {
                        continue;
                    }

                    // eugh! torture!
                    List<string> withoutLabel = bittys.ToList();
                    withoutLabel.RemoveAt(0);
                    bittys = withoutLabel.ToArray();
                }

                string op = bittys[0].Trim();
                
                if (op.Length > 0)
                {
                    // we need to do a check for dw <string> here
                    if (bittys[0] == "dw")
                    {
                        // we just want two 'bits', the dw, and the rest of the arguments.
                        // so if bittys[0] is dw, go back to the original line, find dw, and then substring 
                        int opOffset = line.IndexOf("dw");
                        opOffset += 2;
                        int last = line.LastIndexOf("\"");
                        if (last <= 0)
                        {
                            last = line.Length - opOffset;
                        }
                        else
                        {
                            last -= opOffset - 1;
                        }
                        bittys[1] = line.Substring(opOffset, last).Trim();
                        for (int i = 2; i < bittys.Length; i++)
                        {
                            bittys[i] = "";
                        }
                        
                    }

                    inputs.Add(bittys);
                    inputlines.Add(lineNum);
                    instructionOffset+= 2;
                    if (debug_output)
                        Console.WriteLine(line);
                }
            }

            file.Close();
            
            // resolve 'link labels' and parse
            for (int i = 0; i < inputs.Count; i++ )
            {
                string[] input = inputs[i];
                lineNum = inputlines[i];
                string op = input[0].Trim();
                if (debug_output)
                    Console.WriteLine("Before Link: " + string.Join(";", input));
                linkLabels(input, i*2); // now byte addressing, so PC is line*2
                if (debug_output)
                    Console.WriteLine("After  Link: " + string.Join(";", input));
                if (opmap.ContainsKey(op))
                {
                    try
                    {
                        ops.Add(opmap[op].ParseAndIncUsage(input));
                    }
                    catch (Exception e)
                    {
                        Console.Error.WriteLine("Line " + lineNum + ": Could not parse " + string.Join(" ", input));
                        Console.Error.WriteLine(e.Message);
                        Environment.Exit(4);
                    }

                }
                else
                {
                    Console.Error.WriteLine("Instruction " + op + " is unknown.");
                    return 2;
                }
            }


            // output with correct generator
            string ext = Path.GetExtension(outfile);

            if (ext.Length > 1 && ext[0] == '.')
            {
                ext = ext.Substring(1);
            }

            Console.Out.WriteLine("Instruction usage statistics");
            Console.Out.WriteLine("============================");
            foreach (KeyValuePair<string, OpCodeParser> instParser in opmap)
            {
                Console.Out.WriteLine(instParser.Key + ": " + instParser.Value.Usages);
            }

            if (outmap.ContainsKey(ext))
            {
                try
                {
                    outmap[ext].GenerateOutput(outfile, ops);
                }
                catch (Exception e)
                {
                    Console.Error.WriteLine("Error writing file \"" + outfile + "\":");
                    Console.Error.WriteLine(e.Message);
                }
            }
            else
            {
                Console.Error.WriteLine("Output extension \"" + ext + "\" not supported.");
                return 3;
            }

            return 0;
        }
    }
}
