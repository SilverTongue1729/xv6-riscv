
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8c013103          	ld	sp,-1856(sp) # 800088c0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	add	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	add	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	add	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	sllw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	add	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	sll	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	sll	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	8d070713          	add	a4,a4,-1840 # 80008920 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	f4e78793          	add	a5,a5,-178 # 80005fb0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	or	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	or	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	add	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	add	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	add	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdbe57>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	add	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	add	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	or	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srl	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	add	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	add	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	add	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	add	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	434080e7          	jalr	1076(ra) # 8000255e <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addw	s2,s2,1
    80000144:	0485                	add	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	add	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	add	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	add	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000180:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	8dc50513          	add	a0,a0,-1828 # 80010a60 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	8cc48493          	add	s1,s1,-1844 # 80010a60 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	95c90913          	add	s2,s2,-1700 # 80010af8 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00001097          	auipc	ra,0x1
    800001b8:	7f2080e7          	jalr	2034(ra) # 800019a6 <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	1ec080e7          	jalr	492(ra) # 800023a8 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	f2a080e7          	jalr	-214(ra) # 800020f4 <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	88270713          	add	a4,a4,-1918 # 80010a60 <cons>
    800001e6:	0017869b          	addw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	and	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	add	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	2f8080e7          	jalr	760(ra) # 80002508 <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	add	s4,s4,1
    --n;
    80000220:	39fd                	addw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	83850513          	add	a0,a0,-1992 # 80010a60 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	82250513          	add	a0,a0,-2014 # 80010a60 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a40080e7          	jalr	-1472(ra) # 80000c86 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	add	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	88f72523          	sw	a5,-1910(a4) # 80010af8 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	add	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	add	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	add	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	add	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	add	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00010517          	auipc	a0,0x10
    800002cc:	79850513          	add	a0,a0,1944 # 80010a60 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	2c6080e7          	jalr	710(ra) # 800025b4 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00010517          	auipc	a0,0x10
    800002fa:	76a50513          	add	a0,a0,1898 # 80010a60 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	add	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00010717          	auipc	a4,0x10
    8000031e:	74670713          	add	a4,a4,1862 # 80010a60 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00010797          	auipc	a5,0x10
    80000348:	71c78793          	add	a5,a5,1820 # 80010a60 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	and	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00010797          	auipc	a5,0x10
    80000376:	7867a783          	lw	a5,1926(a5) # 80010af8 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00010717          	auipc	a4,0x10
    8000038a:	6da70713          	add	a4,a4,1754 # 80010a60 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00010497          	auipc	s1,0x10
    8000039a:	6ca48493          	add	s1,s1,1738 # 80010a60 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addw	a5,a5,-1
    800003a6:	07f7f713          	and	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00010717          	auipc	a4,0x10
    800003d6:	68e70713          	add	a4,a4,1678 # 80010a60 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addw	a5,a5,-1
    800003e8:	00010717          	auipc	a4,0x10
    800003ec:	70f72c23          	sw	a5,1816(a4) # 80010b00 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00010797          	auipc	a5,0x10
    80000412:	65278793          	add	a5,a5,1618 # 80010a60 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	and	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00010797          	auipc	a5,0x10
    80000436:	6cc7a523          	sw	a2,1738(a5) # 80010afc <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00010517          	auipc	a0,0x10
    8000043e:	6be50513          	add	a0,a0,1726 # 80010af8 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	d16080e7          	jalr	-746(ra) # 80002158 <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	add	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	add	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	add	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	60450513          	add	a0,a0,1540 # 80010a60 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00021797          	auipc	a5,0x21
    80000478:	39c78793          	add	a5,a5,924 # 80021810 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	add	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	add	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	add	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	add	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	add	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	add	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	add	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	sll	a5,a5,0x20
    800004c8:	9381                	srl	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	add	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	add	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	add	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	add	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addw	a4,a4,-1
    8000050e:	1702                	sll	a4,a4,0x20
    80000510:	9301                	srl	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	add	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	add	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	add	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	add	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00010797          	auipc	a5,0x10
    8000054c:	5c07ac23          	sw	zero,1496(a5) # 80010b20 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	add	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	b5e50513          	add	a0,a0,-1186 # 800080c8 <digits+0x88>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	36f72223          	sw	a5,868(a4) # 800088e0 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	add	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	add	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00010d97          	auipc	s11,0x10
    800005bc:	568dad83          	lw	s11,1384(s11) # 80010b20 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	add	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	add	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	51250513          	add	a0,a0,1298 # 80010b08 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	add	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	add	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	add	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	add	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srl	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	sll	s2,s2,0x4
    800006d4:	34fd                	addw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	add	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	add	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	add	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	add	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	3b450513          	add	a0,a0,948 # 80010b08 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	52a080e7          	jalr	1322(ra) # 80000c86 <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	add	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	add	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	39848493          	add	s1,s1,920 # 80010b08 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	add	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	3c0080e7          	jalr	960(ra) # 80000b42 <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	add	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	add	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	add	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	add	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	35850513          	add	a0,a0,856 # 80010b28 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	add	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	add	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	add	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	0e47a783          	lw	a5,228(a5) # 800088e0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	and	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	404080e7          	jalr	1028(ra) # 80000c26 <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	add	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	0b47b783          	ld	a5,180(a5) # 800088e8 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	0b473703          	ld	a4,180(a4) # 800088f0 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	add	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	add	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	2caa0a13          	add	s4,s4,714 # 80010b28 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	08248493          	add	s1,s1,130 # 800088e8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	08298993          	add	s3,s3,130 # 800088f0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	and	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	and	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	add	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	8c8080e7          	jalr	-1848(ra) # 80002158 <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	add	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	add	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	add	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	25c50513          	add	a0,a0,604 # 80010b28 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	0047a783          	lw	a5,4(a5) # 800088e0 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	00a73703          	ld	a4,10(a4) # 800088f0 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	ffa7b783          	ld	a5,-6(a5) # 800088e8 <uart_tx_r>
    800008f6:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	22e98993          	add	s3,s3,558 # 80010b28 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	fe648493          	add	s1,s1,-26 # 800088e8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	fe690913          	add	s2,s2,-26 # 800088f0 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	7da080e7          	jalr	2010(ra) # 800020f4 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	add	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	1f848493          	add	s1,s1,504 # 80010b28 <uart_tx_lock>
    80000938:	01f77793          	and	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	add	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	fae7b623          	sd	a4,-84(a5) # 800088f0 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	330080e7          	jalr	816(ra) # 80000c86 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	add	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	add	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	add	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	and	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	add	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	add	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	add	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	17248493          	add	s1,s1,370 # 80010b28 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b4080e7          	jalr	692(ra) # 80000c86 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	add	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	add	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	add	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	sll	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00022797          	auipc	a5,0x22
    800009fc:	fb078793          	add	a5,a5,-80 # 800229a8 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	sll	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2be080e7          	jalr	702(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	14890913          	add	s2,s2,328 # 80010b60 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b0080e7          	jalr	432(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	250080e7          	jalr	592(ra) # 80000c86 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	add	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	add	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	add	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	add	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	add	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	add	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	add	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	add	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	0aa50513          	add	a0,a0,170 # 80010b60 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	sll	a1,a1,0x1b
    80000aca:	00022517          	auipc	a0,0x22
    80000ace:	ede50513          	add	a0,a0,-290 # 800229a8 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	add	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	add	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	add	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	07448493          	add	s1,s1,116 # 80010b60 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	05c50513          	add	a0,a0,92 # 80010b60 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	add	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	03050513          	add	a0,a0,48 # 80010b60 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	add	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	add	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	add	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	add	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	add	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	e1e080e7          	jalr	-482(ra) # 8000198a <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	add	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	add	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	dec080e7          	jalr	-532(ra) # 8000198a <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	de0080e7          	jalr	-544(ra) # 8000198a <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	add	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	dc8080e7          	jalr	-568(ra) # 8000198a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srl	s1,s1,0x1
    80000bcc:	8885                	and	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	add	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	add	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	d88080e7          	jalr	-632(ra) # 8000198a <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	add	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	add	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	add	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	add	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	d5c080e7          	jalr	-676(ra) # 8000198a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	and	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	add	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	add	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	add	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	add	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	add	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	add	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	add	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	add	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	sll	a2,a2,0x20
    80000cda:	9201                	srl	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	add	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	add	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	add	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	add	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	sll	a3,a3,0x20
    80000cfe:	9281                	srl	a3,a3,0x20
    80000d00:	0685                	add	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	add	a0,a0,1
    80000d12:	0585                	add	a1,a1,1
  while(n-- > 0){
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x14>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x30>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	6422                	ld	s0,8(sp)
    80000d22:	0141                	add	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	add	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	add	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d30:	c205                	beqz	a2,80000d50 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d32:	02a5e263          	bltu	a1,a0,80000d56 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d36:	1602                	sll	a2,a2,0x20
    80000d38:	9201                	srl	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	add	a1,a1,1
    80000d42:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdc659>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	add	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	sll	a3,a2,0x20
    80000d5a:	9281                	srl	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addw	a5,a2,-1
    80000d6a:	1782                	sll	a5,a5,0x20
    80000d6c:	9381                	srl	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	add	a4,a4,-1
    80000d76:	16fd                	add	a3,a3,-1
    80000d78:	00074603          	lbu	a2,0(a4)
    80000d7c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d80:	fee79ae3          	bne	a5,a4,80000d74 <memmove+0x4a>
    80000d84:	b7f1                	j	80000d50 <memmove+0x26>

0000000080000d86 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d86:	1141                	add	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	add	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	add	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	add	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addw	a2,a2,-1
    80000db6:	0505                	add	a0,a0,1
    80000db8:	0585                	add	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dba:	f675                	bnez	a2,80000da6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbc:	4501                	li	a0,0
    80000dbe:	a809                	j	80000dd0 <strncmp+0x32>
    80000dc0:	4501                	li	a0,0
    80000dc2:	a039                	j	80000dd0 <strncmp+0x32>
  if(n == 0)
    80000dc4:	ca09                	beqz	a2,80000dd6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	add	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	add	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	add	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	add	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	add	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	add	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	add	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	add	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addw	a3,a2,-1
    80000e24:	1682                	sll	a3,a3,0x20
    80000e26:	9281                	srl	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	add	a1,a1,1
    80000e32:	0785                	add	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	add	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	add	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	add	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	add	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	add	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	add	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	add	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b00080e7          	jalr	-1280(ra) # 8000197a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	a7670713          	add	a4,a4,-1418 # 800088f8 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	ae4080e7          	jalr	-1308(ra) # 8000197a <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	add	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	9e8080e7          	jalr	-1560(ra) # 800028a0 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	130080e7          	jalr	304(ra) # 80005ff0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	01e080e7          	jalr	30(ra) # 80001ee6 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	add	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	add	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	add	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b96080e7          	jalr	-1130(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	326080e7          	jalr	806(ra) # 8000123e <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	99e080e7          	jalr	-1634(ra) # 800018c6 <procinit>
    trapinit();      // trap vectors
    80000f30:	00002097          	auipc	ra,0x2
    80000f34:	948080e7          	jalr	-1720(ra) # 80002878 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	968080e7          	jalr	-1688(ra) # 800028a0 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	09a080e7          	jalr	154(ra) # 80005fda <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	0a8080e7          	jalr	168(ra) # 80005ff0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	25a080e7          	jalr	602(ra) # 800031aa <binit>
    iinit();         // inode table
    80000f58:	00003097          	auipc	ra,0x3
    80000f5c:	8f8080e7          	jalr	-1800(ra) # 80003850 <iinit>
    fileinit();      // file table
    80000f60:	00004097          	auipc	ra,0x4
    80000f64:	86e080e7          	jalr	-1938(ra) # 800047ce <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	190080e7          	jalr	400(ra) # 800060f8 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d58080e7          	jalr	-680(ra) # 80001cc8 <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	96f72d23          	sw	a5,-1670(a4) # 800088f8 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	add	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	add	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f8e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f92:	00008797          	auipc	a5,0x8
    80000f96:	96e7b783          	ld	a5,-1682(a5) # 80008900 <kernel_pagetable>
    80000f9a:	83b1                	srl	a5,a5,0xc
    80000f9c:	577d                	li	a4,-1
    80000f9e:	177e                	sll	a4,a4,0x3f
    80000fa0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fa6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000faa:	6422                	ld	s0,8(sp)
    80000fac:	0141                	add	sp,sp,16
    80000fae:	8082                	ret

0000000080000fb0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb0:	7139                	add	sp,sp,-64
    80000fb2:	fc06                	sd	ra,56(sp)
    80000fb4:	f822                	sd	s0,48(sp)
    80000fb6:	f426                	sd	s1,40(sp)
    80000fb8:	f04a                	sd	s2,32(sp)
    80000fba:	ec4e                	sd	s3,24(sp)
    80000fbc:	e852                	sd	s4,16(sp)
    80000fbe:	e456                	sd	s5,8(sp)
    80000fc0:	e05a                	sd	s6,0(sp)
    80000fc2:	0080                	add	s0,sp,64
    80000fc4:	84aa                	mv	s1,a0
    80000fc6:	89ae                	mv	s3,a1
    80000fc8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fca:	57fd                	li	a5,-1
    80000fcc:	83e9                	srl	a5,a5,0x1a
    80000fce:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd2:	04b7f263          	bgeu	a5,a1,80001016 <walk+0x66>
    panic("walk");
    80000fd6:	00007517          	auipc	a0,0x7
    80000fda:	0fa50513          	add	a0,a0,250 # 800080d0 <digits+0x90>
    80000fde:	fffff097          	auipc	ra,0xfffff
    80000fe2:	55e080e7          	jalr	1374(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe6:	060a8663          	beqz	s5,80001052 <walk+0xa2>
    80000fea:	00000097          	auipc	ra,0x0
    80000fee:	af8080e7          	jalr	-1288(ra) # 80000ae2 <kalloc>
    80000ff2:	84aa                	mv	s1,a0
    80000ff4:	c529                	beqz	a0,8000103e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff6:	6605                	lui	a2,0x1
    80000ff8:	4581                	li	a1,0
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	cd4080e7          	jalr	-812(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001002:	00c4d793          	srl	a5,s1,0xc
    80001006:	07aa                	sll	a5,a5,0xa
    80001008:	0017e793          	or	a5,a5,1
    8000100c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001010:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdc64f>
    80001012:	036a0063          	beq	s4,s6,80001032 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001016:	0149d933          	srl	s2,s3,s4
    8000101a:	1ff97913          	and	s2,s2,511
    8000101e:	090e                	sll	s2,s2,0x3
    80001020:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001022:	00093483          	ld	s1,0(s2)
    80001026:	0014f793          	and	a5,s1,1
    8000102a:	dfd5                	beqz	a5,80000fe6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000102c:	80a9                	srl	s1,s1,0xa
    8000102e:	04b2                	sll	s1,s1,0xc
    80001030:	b7c5                	j	80001010 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001032:	00c9d513          	srl	a0,s3,0xc
    80001036:	1ff57513          	and	a0,a0,511
    8000103a:	050e                	sll	a0,a0,0x3
    8000103c:	9526                	add	a0,a0,s1
}
    8000103e:	70e2                	ld	ra,56(sp)
    80001040:	7442                	ld	s0,48(sp)
    80001042:	74a2                	ld	s1,40(sp)
    80001044:	7902                	ld	s2,32(sp)
    80001046:	69e2                	ld	s3,24(sp)
    80001048:	6a42                	ld	s4,16(sp)
    8000104a:	6aa2                	ld	s5,8(sp)
    8000104c:	6b02                	ld	s6,0(sp)
    8000104e:	6121                	add	sp,sp,64
    80001050:	8082                	ret
        return 0;
    80001052:	4501                	li	a0,0
    80001054:	b7ed                	j	8000103e <walk+0x8e>

0000000080001056 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001056:	57fd                	li	a5,-1
    80001058:	83e9                	srl	a5,a5,0x1a
    8000105a:	00b7f463          	bgeu	a5,a1,80001062 <walkaddr+0xc>
    return 0;
    8000105e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001060:	8082                	ret
{
    80001062:	1141                	add	sp,sp,-16
    80001064:	e406                	sd	ra,8(sp)
    80001066:	e022                	sd	s0,0(sp)
    80001068:	0800                	add	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000106a:	4601                	li	a2,0
    8000106c:	00000097          	auipc	ra,0x0
    80001070:	f44080e7          	jalr	-188(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001074:	c105                	beqz	a0,80001094 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001076:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001078:	0117f693          	and	a3,a5,17
    8000107c:	4745                	li	a4,17
    return 0;
    8000107e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001080:	00e68663          	beq	a3,a4,8000108c <walkaddr+0x36>
}
    80001084:	60a2                	ld	ra,8(sp)
    80001086:	6402                	ld	s0,0(sp)
    80001088:	0141                	add	sp,sp,16
    8000108a:	8082                	ret
  pa = PTE2PA(*pte);
    8000108c:	83a9                	srl	a5,a5,0xa
    8000108e:	00c79513          	sll	a0,a5,0xc
  return pa;
    80001092:	bfcd                	j	80001084 <walkaddr+0x2e>
    return 0;
    80001094:	4501                	li	a0,0
    80001096:	b7fd                	j	80001084 <walkaddr+0x2e>

0000000080001098 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001098:	715d                	add	sp,sp,-80
    8000109a:	e486                	sd	ra,72(sp)
    8000109c:	e0a2                	sd	s0,64(sp)
    8000109e:	fc26                	sd	s1,56(sp)
    800010a0:	f84a                	sd	s2,48(sp)
    800010a2:	f44e                	sd	s3,40(sp)
    800010a4:	f052                	sd	s4,32(sp)
    800010a6:	ec56                	sd	s5,24(sp)
    800010a8:	e85a                	sd	s6,16(sp)
    800010aa:	e45e                	sd	s7,8(sp)
    800010ac:	0880                	add	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010ae:	c639                	beqz	a2,800010fc <mappages+0x64>
    800010b0:	8aaa                	mv	s5,a0
    800010b2:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b4:	777d                	lui	a4,0xfffff
    800010b6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ba:	fff58993          	add	s3,a1,-1
    800010be:	99b2                	add	s3,s3,a2
    800010c0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c4:	893e                	mv	s2,a5
    800010c6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ca:	6b85                	lui	s7,0x1
    800010cc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d0:	4605                	li	a2,1
    800010d2:	85ca                	mv	a1,s2
    800010d4:	8556                	mv	a0,s5
    800010d6:	00000097          	auipc	ra,0x0
    800010da:	eda080e7          	jalr	-294(ra) # 80000fb0 <walk>
    800010de:	cd1d                	beqz	a0,8000111c <mappages+0x84>
    if(*pte & PTE_V)
    800010e0:	611c                	ld	a5,0(a0)
    800010e2:	8b85                	and	a5,a5,1
    800010e4:	e785                	bnez	a5,8000110c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e6:	80b1                	srl	s1,s1,0xc
    800010e8:	04aa                	sll	s1,s1,0xa
    800010ea:	0164e4b3          	or	s1,s1,s6
    800010ee:	0014e493          	or	s1,s1,1
    800010f2:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f4:	05390063          	beq	s2,s3,80001134 <mappages+0x9c>
    a += PGSIZE;
    800010f8:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fa:	bfc9                	j	800010cc <mappages+0x34>
    panic("mappages: size");
    800010fc:	00007517          	auipc	a0,0x7
    80001100:	fdc50513          	add	a0,a0,-36 # 800080d8 <digits+0x98>
    80001104:	fffff097          	auipc	ra,0xfffff
    80001108:	438080e7          	jalr	1080(ra) # 8000053c <panic>
      panic("mappages: remap");
    8000110c:	00007517          	auipc	a0,0x7
    80001110:	fdc50513          	add	a0,a0,-36 # 800080e8 <digits+0xa8>
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	428080e7          	jalr	1064(ra) # 8000053c <panic>
      return -1;
    8000111c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111e:	60a6                	ld	ra,72(sp)
    80001120:	6406                	ld	s0,64(sp)
    80001122:	74e2                	ld	s1,56(sp)
    80001124:	7942                	ld	s2,48(sp)
    80001126:	79a2                	ld	s3,40(sp)
    80001128:	7a02                	ld	s4,32(sp)
    8000112a:	6ae2                	ld	s5,24(sp)
    8000112c:	6b42                	ld	s6,16(sp)
    8000112e:	6ba2                	ld	s7,8(sp)
    80001130:	6161                	add	sp,sp,80
    80001132:	8082                	ret
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	b7e5                	j	8000111e <mappages+0x86>

0000000080001138 <kvmmap>:
{
    80001138:	1141                	add	sp,sp,-16
    8000113a:	e406                	sd	ra,8(sp)
    8000113c:	e022                	sd	s0,0(sp)
    8000113e:	0800                	add	s0,sp,16
    80001140:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001142:	86b2                	mv	a3,a2
    80001144:	863e                	mv	a2,a5
    80001146:	00000097          	auipc	ra,0x0
    8000114a:	f52080e7          	jalr	-174(ra) # 80001098 <mappages>
    8000114e:	e509                	bnez	a0,80001158 <kvmmap+0x20>
}
    80001150:	60a2                	ld	ra,8(sp)
    80001152:	6402                	ld	s0,0(sp)
    80001154:	0141                	add	sp,sp,16
    80001156:	8082                	ret
    panic("kvmmap");
    80001158:	00007517          	auipc	a0,0x7
    8000115c:	fa050513          	add	a0,a0,-96 # 800080f8 <digits+0xb8>
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	3dc080e7          	jalr	988(ra) # 8000053c <panic>

0000000080001168 <kvmmake>:
{
    80001168:	1101                	add	sp,sp,-32
    8000116a:	ec06                	sd	ra,24(sp)
    8000116c:	e822                	sd	s0,16(sp)
    8000116e:	e426                	sd	s1,8(sp)
    80001170:	e04a                	sd	s2,0(sp)
    80001172:	1000                	add	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001174:	00000097          	auipc	ra,0x0
    80001178:	96e080e7          	jalr	-1682(ra) # 80000ae2 <kalloc>
    8000117c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117e:	6605                	lui	a2,0x1
    80001180:	4581                	li	a1,0
    80001182:	00000097          	auipc	ra,0x0
    80001186:	b4c080e7          	jalr	-1204(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118a:	4719                	li	a4,6
    8000118c:	6685                	lui	a3,0x1
    8000118e:	10000637          	lui	a2,0x10000
    80001192:	100005b7          	lui	a1,0x10000
    80001196:	8526                	mv	a0,s1
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	fa0080e7          	jalr	-96(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10001637          	lui	a2,0x10001
    800011a8:	100015b7          	lui	a1,0x10001
    800011ac:	8526                	mv	a0,s1
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	f8a080e7          	jalr	-118(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b6:	4719                	li	a4,6
    800011b8:	004006b7          	lui	a3,0x400
    800011bc:	0c000637          	lui	a2,0xc000
    800011c0:	0c0005b7          	lui	a1,0xc000
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f72080e7          	jalr	-142(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ce:	00007917          	auipc	s2,0x7
    800011d2:	e3290913          	add	s2,s2,-462 # 80008000 <etext>
    800011d6:	4729                	li	a4,10
    800011d8:	80007697          	auipc	a3,0x80007
    800011dc:	e2868693          	add	a3,a3,-472 # 8000 <_entry-0x7fff8000>
    800011e0:	4605                	li	a2,1
    800011e2:	067e                	sll	a2,a2,0x1f
    800011e4:	85b2                	mv	a1,a2
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f50080e7          	jalr	-176(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f0:	4719                	li	a4,6
    800011f2:	46c5                	li	a3,17
    800011f4:	06ee                	sll	a3,a3,0x1b
    800011f6:	412686b3          	sub	a3,a3,s2
    800011fa:	864a                	mv	a2,s2
    800011fc:	85ca                	mv	a1,s2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f38080e7          	jalr	-200(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001208:	4729                	li	a4,10
    8000120a:	6685                	lui	a3,0x1
    8000120c:	00006617          	auipc	a2,0x6
    80001210:	df460613          	add	a2,a2,-524 # 80007000 <_trampoline>
    80001214:	040005b7          	lui	a1,0x4000
    80001218:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000121a:	05b2                	sll	a1,a1,0xc
    8000121c:	8526                	mv	a0,s1
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	f1a080e7          	jalr	-230(ra) # 80001138 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001226:	8526                	mv	a0,s1
    80001228:	00000097          	auipc	ra,0x0
    8000122c:	608080e7          	jalr	1544(ra) # 80001830 <proc_mapstacks>
}
    80001230:	8526                	mv	a0,s1
    80001232:	60e2                	ld	ra,24(sp)
    80001234:	6442                	ld	s0,16(sp)
    80001236:	64a2                	ld	s1,8(sp)
    80001238:	6902                	ld	s2,0(sp)
    8000123a:	6105                	add	sp,sp,32
    8000123c:	8082                	ret

000000008000123e <kvminit>:
{
    8000123e:	1141                	add	sp,sp,-16
    80001240:	e406                	sd	ra,8(sp)
    80001242:	e022                	sd	s0,0(sp)
    80001244:	0800                	add	s0,sp,16
  kernel_pagetable = kvmmake();
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f22080e7          	jalr	-222(ra) # 80001168 <kvmmake>
    8000124e:	00007797          	auipc	a5,0x7
    80001252:	6aa7b923          	sd	a0,1714(a5) # 80008900 <kernel_pagetable>
}
    80001256:	60a2                	ld	ra,8(sp)
    80001258:	6402                	ld	s0,0(sp)
    8000125a:	0141                	add	sp,sp,16
    8000125c:	8082                	ret

000000008000125e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125e:	715d                	add	sp,sp,-80
    80001260:	e486                	sd	ra,72(sp)
    80001262:	e0a2                	sd	s0,64(sp)
    80001264:	fc26                	sd	s1,56(sp)
    80001266:	f84a                	sd	s2,48(sp)
    80001268:	f44e                	sd	s3,40(sp)
    8000126a:	f052                	sd	s4,32(sp)
    8000126c:	ec56                	sd	s5,24(sp)
    8000126e:	e85a                	sd	s6,16(sp)
    80001270:	e45e                	sd	s7,8(sp)
    80001272:	0880                	add	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001274:	03459793          	sll	a5,a1,0x34
    80001278:	e795                	bnez	a5,800012a4 <uvmunmap+0x46>
    8000127a:	8a2a                	mv	s4,a0
    8000127c:	892e                	mv	s2,a1
    8000127e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001280:	0632                	sll	a2,a2,0xc
    80001282:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001286:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	6b05                	lui	s6,0x1
    8000128a:	0735e263          	bltu	a1,s3,800012ee <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128e:	60a6                	ld	ra,72(sp)
    80001290:	6406                	ld	s0,64(sp)
    80001292:	74e2                	ld	s1,56(sp)
    80001294:	7942                	ld	s2,48(sp)
    80001296:	79a2                	ld	s3,40(sp)
    80001298:	7a02                	ld	s4,32(sp)
    8000129a:	6ae2                	ld	s5,24(sp)
    8000129c:	6b42                	ld	s6,16(sp)
    8000129e:	6ba2                	ld	s7,8(sp)
    800012a0:	6161                	add	sp,sp,80
    800012a2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a4:	00007517          	auipc	a0,0x7
    800012a8:	e5c50513          	add	a0,a0,-420 # 80008100 <digits+0xc0>
    800012ac:	fffff097          	auipc	ra,0xfffff
    800012b0:	290080e7          	jalr	656(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012b4:	00007517          	auipc	a0,0x7
    800012b8:	e6450513          	add	a0,a0,-412 # 80008118 <digits+0xd8>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	280080e7          	jalr	640(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e6450513          	add	a0,a0,-412 # 80008128 <digits+0xe8>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	270080e7          	jalr	624(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e6c50513          	add	a0,a0,-404 # 80008140 <digits+0x100>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	260080e7          	jalr	608(ra) # 8000053c <panic>
    *pte = 0;
    800012e4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e8:	995a                	add	s2,s2,s6
    800012ea:	fb3972e3          	bgeu	s2,s3,8000128e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ee:	4601                	li	a2,0
    800012f0:	85ca                	mv	a1,s2
    800012f2:	8552                	mv	a0,s4
    800012f4:	00000097          	auipc	ra,0x0
    800012f8:	cbc080e7          	jalr	-836(ra) # 80000fb0 <walk>
    800012fc:	84aa                	mv	s1,a0
    800012fe:	d95d                	beqz	a0,800012b4 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001300:	6108                	ld	a0,0(a0)
    80001302:	00157793          	and	a5,a0,1
    80001306:	dfdd                	beqz	a5,800012c4 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001308:	3ff57793          	and	a5,a0,1023
    8000130c:	fd7784e3          	beq	a5,s7,800012d4 <uvmunmap+0x76>
    if(do_free){
    80001310:	fc0a8ae3          	beqz	s5,800012e4 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001314:	8129                	srl	a0,a0,0xa
      kfree((void*)pa);
    80001316:	0532                	sll	a0,a0,0xc
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	6cc080e7          	jalr	1740(ra) # 800009e4 <kfree>
    80001320:	b7d1                	j	800012e4 <uvmunmap+0x86>

0000000080001322 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001322:	1101                	add	sp,sp,-32
    80001324:	ec06                	sd	ra,24(sp)
    80001326:	e822                	sd	s0,16(sp)
    80001328:	e426                	sd	s1,8(sp)
    8000132a:	1000                	add	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000132c:	fffff097          	auipc	ra,0xfffff
    80001330:	7b6080e7          	jalr	1974(ra) # 80000ae2 <kalloc>
    80001334:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001336:	c519                	beqz	a0,80001344 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001338:	6605                	lui	a2,0x1
    8000133a:	4581                	li	a1,0
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	992080e7          	jalr	-1646(ra) # 80000cce <memset>
  return pagetable;
}
    80001344:	8526                	mv	a0,s1
    80001346:	60e2                	ld	ra,24(sp)
    80001348:	6442                	ld	s0,16(sp)
    8000134a:	64a2                	ld	s1,8(sp)
    8000134c:	6105                	add	sp,sp,32
    8000134e:	8082                	ret

0000000080001350 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001350:	7179                	add	sp,sp,-48
    80001352:	f406                	sd	ra,40(sp)
    80001354:	f022                	sd	s0,32(sp)
    80001356:	ec26                	sd	s1,24(sp)
    80001358:	e84a                	sd	s2,16(sp)
    8000135a:	e44e                	sd	s3,8(sp)
    8000135c:	e052                	sd	s4,0(sp)
    8000135e:	1800                	add	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001360:	6785                	lui	a5,0x1
    80001362:	04f67863          	bgeu	a2,a5,800013b2 <uvmfirst+0x62>
    80001366:	8a2a                	mv	s4,a0
    80001368:	89ae                	mv	s3,a1
    8000136a:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000136c:	fffff097          	auipc	ra,0xfffff
    80001370:	776080e7          	jalr	1910(ra) # 80000ae2 <kalloc>
    80001374:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001376:	6605                	lui	a2,0x1
    80001378:	4581                	li	a1,0
    8000137a:	00000097          	auipc	ra,0x0
    8000137e:	954080e7          	jalr	-1708(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001382:	4779                	li	a4,30
    80001384:	86ca                	mv	a3,s2
    80001386:	6605                	lui	a2,0x1
    80001388:	4581                	li	a1,0
    8000138a:	8552                	mv	a0,s4
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	d0c080e7          	jalr	-756(ra) # 80001098 <mappages>
  memmove(mem, src, sz);
    80001394:	8626                	mv	a2,s1
    80001396:	85ce                	mv	a1,s3
    80001398:	854a                	mv	a0,s2
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	990080e7          	jalr	-1648(ra) # 80000d2a <memmove>
}
    800013a2:	70a2                	ld	ra,40(sp)
    800013a4:	7402                	ld	s0,32(sp)
    800013a6:	64e2                	ld	s1,24(sp)
    800013a8:	6942                	ld	s2,16(sp)
    800013aa:	69a2                	ld	s3,8(sp)
    800013ac:	6a02                	ld	s4,0(sp)
    800013ae:	6145                	add	sp,sp,48
    800013b0:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b2:	00007517          	auipc	a0,0x7
    800013b6:	da650513          	add	a0,a0,-602 # 80008158 <digits+0x118>
    800013ba:	fffff097          	auipc	ra,0xfffff
    800013be:	182080e7          	jalr	386(ra) # 8000053c <panic>

00000000800013c2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c2:	1101                	add	sp,sp,-32
    800013c4:	ec06                	sd	ra,24(sp)
    800013c6:	e822                	sd	s0,16(sp)
    800013c8:	e426                	sd	s1,8(sp)
    800013ca:	1000                	add	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013cc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ce:	00b67d63          	bgeu	a2,a1,800013e8 <uvmdealloc+0x26>
    800013d2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d4:	6785                	lui	a5,0x1
    800013d6:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d8:	00f60733          	add	a4,a2,a5
    800013dc:	76fd                	lui	a3,0xfffff
    800013de:	8f75                	and	a4,a4,a3
    800013e0:	97ae                	add	a5,a5,a1
    800013e2:	8ff5                	and	a5,a5,a3
    800013e4:	00f76863          	bltu	a4,a5,800013f4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e8:	8526                	mv	a0,s1
    800013ea:	60e2                	ld	ra,24(sp)
    800013ec:	6442                	ld	s0,16(sp)
    800013ee:	64a2                	ld	s1,8(sp)
    800013f0:	6105                	add	sp,sp,32
    800013f2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f4:	8f99                	sub	a5,a5,a4
    800013f6:	83b1                	srl	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f8:	4685                	li	a3,1
    800013fa:	0007861b          	sext.w	a2,a5
    800013fe:	85ba                	mv	a1,a4
    80001400:	00000097          	auipc	ra,0x0
    80001404:	e5e080e7          	jalr	-418(ra) # 8000125e <uvmunmap>
    80001408:	b7c5                	j	800013e8 <uvmdealloc+0x26>

000000008000140a <uvmalloc>:
  if(newsz < oldsz)
    8000140a:	0ab66563          	bltu	a2,a1,800014b4 <uvmalloc+0xaa>
{
    8000140e:	7139                	add	sp,sp,-64
    80001410:	fc06                	sd	ra,56(sp)
    80001412:	f822                	sd	s0,48(sp)
    80001414:	f426                	sd	s1,40(sp)
    80001416:	f04a                	sd	s2,32(sp)
    80001418:	ec4e                	sd	s3,24(sp)
    8000141a:	e852                	sd	s4,16(sp)
    8000141c:	e456                	sd	s5,8(sp)
    8000141e:	e05a                	sd	s6,0(sp)
    80001420:	0080                	add	s0,sp,64
    80001422:	8aaa                	mv	s5,a0
    80001424:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001426:	6785                	lui	a5,0x1
    80001428:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000142a:	95be                	add	a1,a1,a5
    8000142c:	77fd                	lui	a5,0xfffff
    8000142e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001432:	08c9f363          	bgeu	s3,a2,800014b8 <uvmalloc+0xae>
    80001436:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001438:	0126eb13          	or	s6,a3,18
    mem = kalloc();
    8000143c:	fffff097          	auipc	ra,0xfffff
    80001440:	6a6080e7          	jalr	1702(ra) # 80000ae2 <kalloc>
    80001444:	84aa                	mv	s1,a0
    if(mem == 0){
    80001446:	c51d                	beqz	a0,80001474 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001448:	6605                	lui	a2,0x1
    8000144a:	4581                	li	a1,0
    8000144c:	00000097          	auipc	ra,0x0
    80001450:	882080e7          	jalr	-1918(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001454:	875a                	mv	a4,s6
    80001456:	86a6                	mv	a3,s1
    80001458:	6605                	lui	a2,0x1
    8000145a:	85ca                	mv	a1,s2
    8000145c:	8556                	mv	a0,s5
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	c3a080e7          	jalr	-966(ra) # 80001098 <mappages>
    80001466:	e90d                	bnez	a0,80001498 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001468:	6785                	lui	a5,0x1
    8000146a:	993e                	add	s2,s2,a5
    8000146c:	fd4968e3          	bltu	s2,s4,8000143c <uvmalloc+0x32>
  return newsz;
    80001470:	8552                	mv	a0,s4
    80001472:	a809                	j	80001484 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001474:	864e                	mv	a2,s3
    80001476:	85ca                	mv	a1,s2
    80001478:	8556                	mv	a0,s5
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	f48080e7          	jalr	-184(ra) # 800013c2 <uvmdealloc>
      return 0;
    80001482:	4501                	li	a0,0
}
    80001484:	70e2                	ld	ra,56(sp)
    80001486:	7442                	ld	s0,48(sp)
    80001488:	74a2                	ld	s1,40(sp)
    8000148a:	7902                	ld	s2,32(sp)
    8000148c:	69e2                	ld	s3,24(sp)
    8000148e:	6a42                	ld	s4,16(sp)
    80001490:	6aa2                	ld	s5,8(sp)
    80001492:	6b02                	ld	s6,0(sp)
    80001494:	6121                	add	sp,sp,64
    80001496:	8082                	ret
      kfree(mem);
    80001498:	8526                	mv	a0,s1
    8000149a:	fffff097          	auipc	ra,0xfffff
    8000149e:	54a080e7          	jalr	1354(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a2:	864e                	mv	a2,s3
    800014a4:	85ca                	mv	a1,s2
    800014a6:	8556                	mv	a0,s5
    800014a8:	00000097          	auipc	ra,0x0
    800014ac:	f1a080e7          	jalr	-230(ra) # 800013c2 <uvmdealloc>
      return 0;
    800014b0:	4501                	li	a0,0
    800014b2:	bfc9                	j	80001484 <uvmalloc+0x7a>
    return oldsz;
    800014b4:	852e                	mv	a0,a1
}
    800014b6:	8082                	ret
  return newsz;
    800014b8:	8532                	mv	a0,a2
    800014ba:	b7e9                	j	80001484 <uvmalloc+0x7a>

00000000800014bc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014bc:	7179                	add	sp,sp,-48
    800014be:	f406                	sd	ra,40(sp)
    800014c0:	f022                	sd	s0,32(sp)
    800014c2:	ec26                	sd	s1,24(sp)
    800014c4:	e84a                	sd	s2,16(sp)
    800014c6:	e44e                	sd	s3,8(sp)
    800014c8:	e052                	sd	s4,0(sp)
    800014ca:	1800                	add	s0,sp,48
    800014cc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014ce:	84aa                	mv	s1,a0
    800014d0:	6905                	lui	s2,0x1
    800014d2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d4:	4985                	li	s3,1
    800014d6:	a829                	j	800014f0 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d8:	83a9                	srl	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014da:	00c79513          	sll	a0,a5,0xc
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	fde080e7          	jalr	-34(ra) # 800014bc <freewalk>
      pagetable[i] = 0;
    800014e6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ea:	04a1                	add	s1,s1,8
    800014ec:	03248163          	beq	s1,s2,8000150e <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f2:	00f7f713          	and	a4,a5,15
    800014f6:	ff3701e3          	beq	a4,s3,800014d8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fa:	8b85                	and	a5,a5,1
    800014fc:	d7fd                	beqz	a5,800014ea <freewalk+0x2e>
      panic("freewalk: leaf");
    800014fe:	00007517          	auipc	a0,0x7
    80001502:	c7a50513          	add	a0,a0,-902 # 80008178 <digits+0x138>
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	036080e7          	jalr	54(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    8000150e:	8552                	mv	a0,s4
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	4d4080e7          	jalr	1236(ra) # 800009e4 <kfree>
}
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	64e2                	ld	s1,24(sp)
    8000151e:	6942                	ld	s2,16(sp)
    80001520:	69a2                	ld	s3,8(sp)
    80001522:	6a02                	ld	s4,0(sp)
    80001524:	6145                	add	sp,sp,48
    80001526:	8082                	ret

0000000080001528 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001528:	1101                	add	sp,sp,-32
    8000152a:	ec06                	sd	ra,24(sp)
    8000152c:	e822                	sd	s0,16(sp)
    8000152e:	e426                	sd	s1,8(sp)
    80001530:	1000                	add	s0,sp,32
    80001532:	84aa                	mv	s1,a0
  if(sz > 0)
    80001534:	e999                	bnez	a1,8000154a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001536:	8526                	mv	a0,s1
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	f84080e7          	jalr	-124(ra) # 800014bc <freewalk>
}
    80001540:	60e2                	ld	ra,24(sp)
    80001542:	6442                	ld	s0,16(sp)
    80001544:	64a2                	ld	s1,8(sp)
    80001546:	6105                	add	sp,sp,32
    80001548:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154a:	6785                	lui	a5,0x1
    8000154c:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000154e:	95be                	add	a1,a1,a5
    80001550:	4685                	li	a3,1
    80001552:	00c5d613          	srl	a2,a1,0xc
    80001556:	4581                	li	a1,0
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	d06080e7          	jalr	-762(ra) # 8000125e <uvmunmap>
    80001560:	bfd9                	j	80001536 <uvmfree+0xe>

0000000080001562 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001562:	c679                	beqz	a2,80001630 <uvmcopy+0xce>
{
    80001564:	715d                	add	sp,sp,-80
    80001566:	e486                	sd	ra,72(sp)
    80001568:	e0a2                	sd	s0,64(sp)
    8000156a:	fc26                	sd	s1,56(sp)
    8000156c:	f84a                	sd	s2,48(sp)
    8000156e:	f44e                	sd	s3,40(sp)
    80001570:	f052                	sd	s4,32(sp)
    80001572:	ec56                	sd	s5,24(sp)
    80001574:	e85a                	sd	s6,16(sp)
    80001576:	e45e                	sd	s7,8(sp)
    80001578:	0880                	add	s0,sp,80
    8000157a:	8b2a                	mv	s6,a0
    8000157c:	8aae                	mv	s5,a1
    8000157e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001580:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001582:	4601                	li	a2,0
    80001584:	85ce                	mv	a1,s3
    80001586:	855a                	mv	a0,s6
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	a28080e7          	jalr	-1496(ra) # 80000fb0 <walk>
    80001590:	c531                	beqz	a0,800015dc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001592:	6118                	ld	a4,0(a0)
    80001594:	00177793          	and	a5,a4,1
    80001598:	cbb1                	beqz	a5,800015ec <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159a:	00a75593          	srl	a1,a4,0xa
    8000159e:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a2:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	53c080e7          	jalr	1340(ra) # 80000ae2 <kalloc>
    800015ae:	892a                	mv	s2,a0
    800015b0:	c939                	beqz	a0,80001606 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b2:	6605                	lui	a2,0x1
    800015b4:	85de                	mv	a1,s7
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	774080e7          	jalr	1908(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015be:	8726                	mv	a4,s1
    800015c0:	86ca                	mv	a3,s2
    800015c2:	6605                	lui	a2,0x1
    800015c4:	85ce                	mv	a1,s3
    800015c6:	8556                	mv	a0,s5
    800015c8:	00000097          	auipc	ra,0x0
    800015cc:	ad0080e7          	jalr	-1328(ra) # 80001098 <mappages>
    800015d0:	e515                	bnez	a0,800015fc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d2:	6785                	lui	a5,0x1
    800015d4:	99be                	add	s3,s3,a5
    800015d6:	fb49e6e3          	bltu	s3,s4,80001582 <uvmcopy+0x20>
    800015da:	a081                	j	8000161a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015dc:	00007517          	auipc	a0,0x7
    800015e0:	bac50513          	add	a0,a0,-1108 # 80008188 <digits+0x148>
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	f58080e7          	jalr	-168(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015ec:	00007517          	auipc	a0,0x7
    800015f0:	bbc50513          	add	a0,a0,-1092 # 800081a8 <digits+0x168>
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	f48080e7          	jalr	-184(ra) # 8000053c <panic>
      kfree(mem);
    800015fc:	854a                	mv	a0,s2
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	3e6080e7          	jalr	998(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001606:	4685                	li	a3,1
    80001608:	00c9d613          	srl	a2,s3,0xc
    8000160c:	4581                	li	a1,0
    8000160e:	8556                	mv	a0,s5
    80001610:	00000097          	auipc	ra,0x0
    80001614:	c4e080e7          	jalr	-946(ra) # 8000125e <uvmunmap>
  return -1;
    80001618:	557d                	li	a0,-1
}
    8000161a:	60a6                	ld	ra,72(sp)
    8000161c:	6406                	ld	s0,64(sp)
    8000161e:	74e2                	ld	s1,56(sp)
    80001620:	7942                	ld	s2,48(sp)
    80001622:	79a2                	ld	s3,40(sp)
    80001624:	7a02                	ld	s4,32(sp)
    80001626:	6ae2                	ld	s5,24(sp)
    80001628:	6b42                	ld	s6,16(sp)
    8000162a:	6ba2                	ld	s7,8(sp)
    8000162c:	6161                	add	sp,sp,80
    8000162e:	8082                	ret
  return 0;
    80001630:	4501                	li	a0,0
}
    80001632:	8082                	ret

0000000080001634 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001634:	1141                	add	sp,sp,-16
    80001636:	e406                	sd	ra,8(sp)
    80001638:	e022                	sd	s0,0(sp)
    8000163a:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163c:	4601                	li	a2,0
    8000163e:	00000097          	auipc	ra,0x0
    80001642:	972080e7          	jalr	-1678(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001646:	c901                	beqz	a0,80001656 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001648:	611c                	ld	a5,0(a0)
    8000164a:	9bbd                	and	a5,a5,-17
    8000164c:	e11c                	sd	a5,0(a0)
}
    8000164e:	60a2                	ld	ra,8(sp)
    80001650:	6402                	ld	s0,0(sp)
    80001652:	0141                	add	sp,sp,16
    80001654:	8082                	ret
    panic("uvmclear");
    80001656:	00007517          	auipc	a0,0x7
    8000165a:	b7250513          	add	a0,a0,-1166 # 800081c8 <digits+0x188>
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	ede080e7          	jalr	-290(ra) # 8000053c <panic>

0000000080001666 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001666:	c6bd                	beqz	a3,800016d4 <copyout+0x6e>
{
    80001668:	715d                	add	sp,sp,-80
    8000166a:	e486                	sd	ra,72(sp)
    8000166c:	e0a2                	sd	s0,64(sp)
    8000166e:	fc26                	sd	s1,56(sp)
    80001670:	f84a                	sd	s2,48(sp)
    80001672:	f44e                	sd	s3,40(sp)
    80001674:	f052                	sd	s4,32(sp)
    80001676:	ec56                	sd	s5,24(sp)
    80001678:	e85a                	sd	s6,16(sp)
    8000167a:	e45e                	sd	s7,8(sp)
    8000167c:	e062                	sd	s8,0(sp)
    8000167e:	0880                	add	s0,sp,80
    80001680:	8b2a                	mv	s6,a0
    80001682:	8c2e                	mv	s8,a1
    80001684:	8a32                	mv	s4,a2
    80001686:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001688:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168a:	6a85                	lui	s5,0x1
    8000168c:	a015                	j	800016b0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168e:	9562                	add	a0,a0,s8
    80001690:	0004861b          	sext.w	a2,s1
    80001694:	85d2                	mv	a1,s4
    80001696:	41250533          	sub	a0,a0,s2
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	690080e7          	jalr	1680(ra) # 80000d2a <memmove>

    len -= n;
    800016a2:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ac:	02098263          	beqz	s3,800016d0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b4:	85ca                	mv	a1,s2
    800016b6:	855a                	mv	a0,s6
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	99e080e7          	jalr	-1634(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800016c0:	cd01                	beqz	a0,800016d8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c2:	418904b3          	sub	s1,s2,s8
    800016c6:	94d6                	add	s1,s1,s5
    800016c8:	fc99f3e3          	bgeu	s3,s1,8000168e <copyout+0x28>
    800016cc:	84ce                	mv	s1,s3
    800016ce:	b7c1                	j	8000168e <copyout+0x28>
  }
  return 0;
    800016d0:	4501                	li	a0,0
    800016d2:	a021                	j	800016da <copyout+0x74>
    800016d4:	4501                	li	a0,0
}
    800016d6:	8082                	ret
      return -1;
    800016d8:	557d                	li	a0,-1
}
    800016da:	60a6                	ld	ra,72(sp)
    800016dc:	6406                	ld	s0,64(sp)
    800016de:	74e2                	ld	s1,56(sp)
    800016e0:	7942                	ld	s2,48(sp)
    800016e2:	79a2                	ld	s3,40(sp)
    800016e4:	7a02                	ld	s4,32(sp)
    800016e6:	6ae2                	ld	s5,24(sp)
    800016e8:	6b42                	ld	s6,16(sp)
    800016ea:	6ba2                	ld	s7,8(sp)
    800016ec:	6c02                	ld	s8,0(sp)
    800016ee:	6161                	add	sp,sp,80
    800016f0:	8082                	ret

00000000800016f2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f2:	caa5                	beqz	a3,80001762 <copyin+0x70>
{
    800016f4:	715d                	add	sp,sp,-80
    800016f6:	e486                	sd	ra,72(sp)
    800016f8:	e0a2                	sd	s0,64(sp)
    800016fa:	fc26                	sd	s1,56(sp)
    800016fc:	f84a                	sd	s2,48(sp)
    800016fe:	f44e                	sd	s3,40(sp)
    80001700:	f052                	sd	s4,32(sp)
    80001702:	ec56                	sd	s5,24(sp)
    80001704:	e85a                	sd	s6,16(sp)
    80001706:	e45e                	sd	s7,8(sp)
    80001708:	e062                	sd	s8,0(sp)
    8000170a:	0880                	add	s0,sp,80
    8000170c:	8b2a                	mv	s6,a0
    8000170e:	8a2e                	mv	s4,a1
    80001710:	8c32                	mv	s8,a2
    80001712:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001714:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001716:	6a85                	lui	s5,0x1
    80001718:	a01d                	j	8000173e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171a:	018505b3          	add	a1,a0,s8
    8000171e:	0004861b          	sext.w	a2,s1
    80001722:	412585b3          	sub	a1,a1,s2
    80001726:	8552                	mv	a0,s4
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	602080e7          	jalr	1538(ra) # 80000d2a <memmove>

    len -= n;
    80001730:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001734:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001736:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173a:	02098263          	beqz	s3,8000175e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001742:	85ca                	mv	a1,s2
    80001744:	855a                	mv	a0,s6
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	910080e7          	jalr	-1776(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    8000174e:	cd01                	beqz	a0,80001766 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001750:	418904b3          	sub	s1,s2,s8
    80001754:	94d6                	add	s1,s1,s5
    80001756:	fc99f2e3          	bgeu	s3,s1,8000171a <copyin+0x28>
    8000175a:	84ce                	mv	s1,s3
    8000175c:	bf7d                	j	8000171a <copyin+0x28>
  }
  return 0;
    8000175e:	4501                	li	a0,0
    80001760:	a021                	j	80001768 <copyin+0x76>
    80001762:	4501                	li	a0,0
}
    80001764:	8082                	ret
      return -1;
    80001766:	557d                	li	a0,-1
}
    80001768:	60a6                	ld	ra,72(sp)
    8000176a:	6406                	ld	s0,64(sp)
    8000176c:	74e2                	ld	s1,56(sp)
    8000176e:	7942                	ld	s2,48(sp)
    80001770:	79a2                	ld	s3,40(sp)
    80001772:	7a02                	ld	s4,32(sp)
    80001774:	6ae2                	ld	s5,24(sp)
    80001776:	6b42                	ld	s6,16(sp)
    80001778:	6ba2                	ld	s7,8(sp)
    8000177a:	6c02                	ld	s8,0(sp)
    8000177c:	6161                	add	sp,sp,80
    8000177e:	8082                	ret

0000000080001780 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001780:	c2dd                	beqz	a3,80001826 <copyinstr+0xa6>
{
    80001782:	715d                	add	sp,sp,-80
    80001784:	e486                	sd	ra,72(sp)
    80001786:	e0a2                	sd	s0,64(sp)
    80001788:	fc26                	sd	s1,56(sp)
    8000178a:	f84a                	sd	s2,48(sp)
    8000178c:	f44e                	sd	s3,40(sp)
    8000178e:	f052                	sd	s4,32(sp)
    80001790:	ec56                	sd	s5,24(sp)
    80001792:	e85a                	sd	s6,16(sp)
    80001794:	e45e                	sd	s7,8(sp)
    80001796:	0880                	add	s0,sp,80
    80001798:	8a2a                	mv	s4,a0
    8000179a:	8b2e                	mv	s6,a1
    8000179c:	8bb2                	mv	s7,a2
    8000179e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a2:	6985                	lui	s3,0x1
    800017a4:	a02d                	j	800017ce <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017aa:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ac:	37fd                	addw	a5,a5,-1
    800017ae:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b2:	60a6                	ld	ra,72(sp)
    800017b4:	6406                	ld	s0,64(sp)
    800017b6:	74e2                	ld	s1,56(sp)
    800017b8:	7942                	ld	s2,48(sp)
    800017ba:	79a2                	ld	s3,40(sp)
    800017bc:	7a02                	ld	s4,32(sp)
    800017be:	6ae2                	ld	s5,24(sp)
    800017c0:	6b42                	ld	s6,16(sp)
    800017c2:	6ba2                	ld	s7,8(sp)
    800017c4:	6161                	add	sp,sp,80
    800017c6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017cc:	c8a9                	beqz	s1,8000181e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017ce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d2:	85ca                	mv	a1,s2
    800017d4:	8552                	mv	a0,s4
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	880080e7          	jalr	-1920(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800017de:	c131                	beqz	a0,80001822 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e0:	417906b3          	sub	a3,s2,s7
    800017e4:	96ce                	add	a3,a3,s3
    800017e6:	00d4f363          	bgeu	s1,a3,800017ec <copyinstr+0x6c>
    800017ea:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ec:	955e                	add	a0,a0,s7
    800017ee:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f2:	daf9                	beqz	a3,800017c8 <copyinstr+0x48>
    800017f4:	87da                	mv	a5,s6
    800017f6:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017f8:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017fc:	96da                	add	a3,a3,s6
    800017fe:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001800:	00f60733          	add	a4,a2,a5
    80001804:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdc658>
    80001808:	df59                	beqz	a4,800017a6 <copyinstr+0x26>
        *dst = *p;
    8000180a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000180e:	0785                	add	a5,a5,1
    while(n > 0){
    80001810:	fed797e3          	bne	a5,a3,800017fe <copyinstr+0x7e>
    80001814:	14fd                	add	s1,s1,-1
    80001816:	94c2                	add	s1,s1,a6
      --max;
    80001818:	8c8d                	sub	s1,s1,a1
      dst++;
    8000181a:	8b3e                	mv	s6,a5
    8000181c:	b775                	j	800017c8 <copyinstr+0x48>
    8000181e:	4781                	li	a5,0
    80001820:	b771                	j	800017ac <copyinstr+0x2c>
      return -1;
    80001822:	557d                	li	a0,-1
    80001824:	b779                	j	800017b2 <copyinstr+0x32>
  int got_null = 0;
    80001826:	4781                	li	a5,0
  if(got_null){
    80001828:	37fd                	addw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
}
    8000182e:	8082                	ret

0000000080001830 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
    80001830:	7139                	add	sp,sp,-64
    80001832:	fc06                	sd	ra,56(sp)
    80001834:	f822                	sd	s0,48(sp)
    80001836:	f426                	sd	s1,40(sp)
    80001838:	f04a                	sd	s2,32(sp)
    8000183a:	ec4e                	sd	s3,24(sp)
    8000183c:	e852                	sd	s4,16(sp)
    8000183e:	e456                	sd	s5,8(sp)
    80001840:	e05a                	sd	s6,0(sp)
    80001842:	0080                	add	s0,sp,64
    80001844:	89aa                	mv	s3,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    80001846:	0000f497          	auipc	s1,0xf
    8000184a:	76a48493          	add	s1,s1,1898 # 80010fb0 <proc>
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    8000184e:	8b26                	mv	s6,s1
    80001850:	00006a97          	auipc	s5,0x6
    80001854:	7b0a8a93          	add	s5,s5,1968 # 80008000 <etext>
    80001858:	04000937          	lui	s2,0x4000
    8000185c:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000185e:	0932                	sll	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    80001860:	00016a17          	auipc	s4,0x16
    80001864:	d50a0a13          	add	s4,s4,-688 # 800175b0 <tickslock>
    char *pa = kalloc();
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	27a080e7          	jalr	634(ra) # 80000ae2 <kalloc>
    80001870:	862a                	mv	a2,a0
    if (pa == 0)
    80001872:	c131                	beqz	a0,800018b6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int)(p - proc));
    80001874:	416485b3          	sub	a1,s1,s6
    80001878:	858d                	sra	a1,a1,0x3
    8000187a:	000ab783          	ld	a5,0(s5)
    8000187e:	02f585b3          	mul	a1,a1,a5
    80001882:	2585                	addw	a1,a1,1
    80001884:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001888:	4719                	li	a4,6
    8000188a:	6685                	lui	a3,0x1
    8000188c:	40b905b3          	sub	a1,s2,a1
    80001890:	854e                	mv	a0,s3
    80001892:	00000097          	auipc	ra,0x0
    80001896:	8a6080e7          	jalr	-1882(ra) # 80001138 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++)
    8000189a:	19848493          	add	s1,s1,408
    8000189e:	fd4495e3          	bne	s1,s4,80001868 <proc_mapstacks+0x38>
  }
}
    800018a2:	70e2                	ld	ra,56(sp)
    800018a4:	7442                	ld	s0,48(sp)
    800018a6:	74a2                	ld	s1,40(sp)
    800018a8:	7902                	ld	s2,32(sp)
    800018aa:	69e2                	ld	s3,24(sp)
    800018ac:	6a42                	ld	s4,16(sp)
    800018ae:	6aa2                	ld	s5,8(sp)
    800018b0:	6b02                	ld	s6,0(sp)
    800018b2:	6121                	add	sp,sp,64
    800018b4:	8082                	ret
      panic("kalloc");
    800018b6:	00007517          	auipc	a0,0x7
    800018ba:	92250513          	add	a0,a0,-1758 # 800081d8 <digits+0x198>
    800018be:	fffff097          	auipc	ra,0xfffff
    800018c2:	c7e080e7          	jalr	-898(ra) # 8000053c <panic>

00000000800018c6 <procinit>:

// initialize the proc table.
void procinit(void)
{
    800018c6:	7139                	add	sp,sp,-64
    800018c8:	fc06                	sd	ra,56(sp)
    800018ca:	f822                	sd	s0,48(sp)
    800018cc:	f426                	sd	s1,40(sp)
    800018ce:	f04a                	sd	s2,32(sp)
    800018d0:	ec4e                	sd	s3,24(sp)
    800018d2:	e852                	sd	s4,16(sp)
    800018d4:	e456                	sd	s5,8(sp)
    800018d6:	e05a                	sd	s6,0(sp)
    800018d8:	0080                	add	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800018da:	00007597          	auipc	a1,0x7
    800018de:	90658593          	add	a1,a1,-1786 # 800081e0 <digits+0x1a0>
    800018e2:	0000f517          	auipc	a0,0xf
    800018e6:	29e50513          	add	a0,a0,670 # 80010b80 <pid_lock>
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	258080e7          	jalr	600(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f2:	00007597          	auipc	a1,0x7
    800018f6:	8f658593          	add	a1,a1,-1802 # 800081e8 <digits+0x1a8>
    800018fa:	0000f517          	auipc	a0,0xf
    800018fe:	29e50513          	add	a0,a0,670 # 80010b98 <wait_lock>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	240080e7          	jalr	576(ra) # 80000b42 <initlock>
  for (p = proc; p < &proc[NPROC]; p++)
    8000190a:	0000f497          	auipc	s1,0xf
    8000190e:	6a648493          	add	s1,s1,1702 # 80010fb0 <proc>
  {
    initlock(&p->lock, "proc");
    80001912:	00007b17          	auipc	s6,0x7
    80001916:	8e6b0b13          	add	s6,s6,-1818 # 800081f8 <digits+0x1b8>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000191a:	8aa6                	mv	s5,s1
    8000191c:	00006a17          	auipc	s4,0x6
    80001920:	6e4a0a13          	add	s4,s4,1764 # 80008000 <etext>
    80001924:	04000937          	lui	s2,0x4000
    80001928:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000192a:	0932                	sll	s2,s2,0xc
  for (p = proc; p < &proc[NPROC]; p++)
    8000192c:	00016997          	auipc	s3,0x16
    80001930:	c8498993          	add	s3,s3,-892 # 800175b0 <tickslock>
    initlock(&p->lock, "proc");
    80001934:	85da                	mv	a1,s6
    80001936:	8526                	mv	a0,s1
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	20a080e7          	jalr	522(ra) # 80000b42 <initlock>
    p->state = UNUSED;
    80001940:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001944:	415487b3          	sub	a5,s1,s5
    80001948:	878d                	sra	a5,a5,0x3
    8000194a:	000a3703          	ld	a4,0(s4)
    8000194e:	02e787b3          	mul	a5,a5,a4
    80001952:	2785                	addw	a5,a5,1
    80001954:	00d7979b          	sllw	a5,a5,0xd
    80001958:	40f907b3          	sub	a5,s2,a5
    8000195c:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++)
    8000195e:	19848493          	add	s1,s1,408
    80001962:	fd3499e3          	bne	s1,s3,80001934 <procinit+0x6e>
  }
}
    80001966:	70e2                	ld	ra,56(sp)
    80001968:	7442                	ld	s0,48(sp)
    8000196a:	74a2                	ld	s1,40(sp)
    8000196c:	7902                	ld	s2,32(sp)
    8000196e:	69e2                	ld	s3,24(sp)
    80001970:	6a42                	ld	s4,16(sp)
    80001972:	6aa2                	ld	s5,8(sp)
    80001974:	6b02                	ld	s6,0(sp)
    80001976:	6121                	add	sp,sp,64
    80001978:	8082                	ret

000000008000197a <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
    8000197a:	1141                	add	sp,sp,-16
    8000197c:	e422                	sd	s0,8(sp)
    8000197e:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001980:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001982:	2501                	sext.w	a0,a0
    80001984:	6422                	ld	s0,8(sp)
    80001986:	0141                	add	sp,sp,16
    80001988:	8082                	ret

000000008000198a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    8000198a:	1141                	add	sp,sp,-16
    8000198c:	e422                	sd	s0,8(sp)
    8000198e:	0800                	add	s0,sp,16
    80001990:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001992:	2781                	sext.w	a5,a5
    80001994:	079e                	sll	a5,a5,0x7
  return c;
}
    80001996:	0000f517          	auipc	a0,0xf
    8000199a:	21a50513          	add	a0,a0,538 # 80010bb0 <cpus>
    8000199e:	953e                	add	a0,a0,a5
    800019a0:	6422                	ld	s0,8(sp)
    800019a2:	0141                	add	sp,sp,16
    800019a4:	8082                	ret

00000000800019a6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800019a6:	1101                	add	sp,sp,-32
    800019a8:	ec06                	sd	ra,24(sp)
    800019aa:	e822                	sd	s0,16(sp)
    800019ac:	e426                	sd	s1,8(sp)
    800019ae:	1000                	add	s0,sp,32
  push_off();
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	1d6080e7          	jalr	470(ra) # 80000b86 <push_off>
    800019b8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019ba:	2781                	sext.w	a5,a5
    800019bc:	079e                	sll	a5,a5,0x7
    800019be:	0000f717          	auipc	a4,0xf
    800019c2:	1c270713          	add	a4,a4,450 # 80010b80 <pid_lock>
    800019c6:	97ba                	add	a5,a5,a4
    800019c8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	25c080e7          	jalr	604(ra) # 80000c26 <pop_off>
  return p;
}
    800019d2:	8526                	mv	a0,s1
    800019d4:	60e2                	ld	ra,24(sp)
    800019d6:	6442                	ld	s0,16(sp)
    800019d8:	64a2                	ld	s1,8(sp)
    800019da:	6105                	add	sp,sp,32
    800019dc:	8082                	ret

00000000800019de <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    800019de:	1141                	add	sp,sp,-16
    800019e0:	e406                	sd	ra,8(sp)
    800019e2:	e022                	sd	s0,0(sp)
    800019e4:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019e6:	00000097          	auipc	ra,0x0
    800019ea:	fc0080e7          	jalr	-64(ra) # 800019a6 <myproc>
    800019ee:	fffff097          	auipc	ra,0xfffff
    800019f2:	298080e7          	jalr	664(ra) # 80000c86 <release>

  if (first)
    800019f6:	00007797          	auipc	a5,0x7
    800019fa:	e7a7a783          	lw	a5,-390(a5) # 80008870 <first.1>
    800019fe:	eb89                	bnez	a5,80001a10 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a00:	00001097          	auipc	ra,0x1
    80001a04:	eb8080e7          	jalr	-328(ra) # 800028b8 <usertrapret>
}
    80001a08:	60a2                	ld	ra,8(sp)
    80001a0a:	6402                	ld	s0,0(sp)
    80001a0c:	0141                	add	sp,sp,16
    80001a0e:	8082                	ret
    first = 0;
    80001a10:	00007797          	auipc	a5,0x7
    80001a14:	e607a023          	sw	zero,-416(a5) # 80008870 <first.1>
    fsinit(ROOTDEV);
    80001a18:	4505                	li	a0,1
    80001a1a:	00002097          	auipc	ra,0x2
    80001a1e:	db6080e7          	jalr	-586(ra) # 800037d0 <fsinit>
    80001a22:	bff9                	j	80001a00 <forkret+0x22>

0000000080001a24 <allocpid>:
{
    80001a24:	1101                	add	sp,sp,-32
    80001a26:	ec06                	sd	ra,24(sp)
    80001a28:	e822                	sd	s0,16(sp)
    80001a2a:	e426                	sd	s1,8(sp)
    80001a2c:	e04a                	sd	s2,0(sp)
    80001a2e:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001a30:	0000f917          	auipc	s2,0xf
    80001a34:	15090913          	add	s2,s2,336 # 80010b80 <pid_lock>
    80001a38:	854a                	mv	a0,s2
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	198080e7          	jalr	408(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a42:	00007797          	auipc	a5,0x7
    80001a46:	e3278793          	add	a5,a5,-462 # 80008874 <nextpid>
    80001a4a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a4c:	0014871b          	addw	a4,s1,1
    80001a50:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a52:	854a                	mv	a0,s2
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	232080e7          	jalr	562(ra) # 80000c86 <release>
}
    80001a5c:	8526                	mv	a0,s1
    80001a5e:	60e2                	ld	ra,24(sp)
    80001a60:	6442                	ld	s0,16(sp)
    80001a62:	64a2                	ld	s1,8(sp)
    80001a64:	6902                	ld	s2,0(sp)
    80001a66:	6105                	add	sp,sp,32
    80001a68:	8082                	ret

0000000080001a6a <proc_pagetable>:
{
    80001a6a:	1101                	add	sp,sp,-32
    80001a6c:	ec06                	sd	ra,24(sp)
    80001a6e:	e822                	sd	s0,16(sp)
    80001a70:	e426                	sd	s1,8(sp)
    80001a72:	e04a                	sd	s2,0(sp)
    80001a74:	1000                	add	s0,sp,32
    80001a76:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a78:	00000097          	auipc	ra,0x0
    80001a7c:	8aa080e7          	jalr	-1878(ra) # 80001322 <uvmcreate>
    80001a80:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a82:	c121                	beqz	a0,80001ac2 <proc_pagetable+0x58>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a84:	4729                	li	a4,10
    80001a86:	00005697          	auipc	a3,0x5
    80001a8a:	57a68693          	add	a3,a3,1402 # 80007000 <_trampoline>
    80001a8e:	6605                	lui	a2,0x1
    80001a90:	040005b7          	lui	a1,0x4000
    80001a94:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a96:	05b2                	sll	a1,a1,0xc
    80001a98:	fffff097          	auipc	ra,0xfffff
    80001a9c:	600080e7          	jalr	1536(ra) # 80001098 <mappages>
    80001aa0:	02054863          	bltz	a0,80001ad0 <proc_pagetable+0x66>
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aa4:	4719                	li	a4,6
    80001aa6:	05893683          	ld	a3,88(s2)
    80001aaa:	6605                	lui	a2,0x1
    80001aac:	020005b7          	lui	a1,0x2000
    80001ab0:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ab2:	05b6                	sll	a1,a1,0xd
    80001ab4:	8526                	mv	a0,s1
    80001ab6:	fffff097          	auipc	ra,0xfffff
    80001aba:	5e2080e7          	jalr	1506(ra) # 80001098 <mappages>
    80001abe:	02054163          	bltz	a0,80001ae0 <proc_pagetable+0x76>
}
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	60e2                	ld	ra,24(sp)
    80001ac6:	6442                	ld	s0,16(sp)
    80001ac8:	64a2                	ld	s1,8(sp)
    80001aca:	6902                	ld	s2,0(sp)
    80001acc:	6105                	add	sp,sp,32
    80001ace:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad0:	4581                	li	a1,0
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	00000097          	auipc	ra,0x0
    80001ad8:	a54080e7          	jalr	-1452(ra) # 80001528 <uvmfree>
    return 0;
    80001adc:	4481                	li	s1,0
    80001ade:	b7d5                	j	80001ac2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae0:	4681                	li	a3,0
    80001ae2:	4605                	li	a2,1
    80001ae4:	040005b7          	lui	a1,0x4000
    80001ae8:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aea:	05b2                	sll	a1,a1,0xc
    80001aec:	8526                	mv	a0,s1
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	770080e7          	jalr	1904(ra) # 8000125e <uvmunmap>
    uvmfree(pagetable, 0);
    80001af6:	4581                	li	a1,0
    80001af8:	8526                	mv	a0,s1
    80001afa:	00000097          	auipc	ra,0x0
    80001afe:	a2e080e7          	jalr	-1490(ra) # 80001528 <uvmfree>
    return 0;
    80001b02:	4481                	li	s1,0
    80001b04:	bf7d                	j	80001ac2 <proc_pagetable+0x58>

0000000080001b06 <proc_freepagetable>:
{
    80001b06:	1101                	add	sp,sp,-32
    80001b08:	ec06                	sd	ra,24(sp)
    80001b0a:	e822                	sd	s0,16(sp)
    80001b0c:	e426                	sd	s1,8(sp)
    80001b0e:	e04a                	sd	s2,0(sp)
    80001b10:	1000                	add	s0,sp,32
    80001b12:	84aa                	mv	s1,a0
    80001b14:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b16:	4681                	li	a3,0
    80001b18:	4605                	li	a2,1
    80001b1a:	040005b7          	lui	a1,0x4000
    80001b1e:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b20:	05b2                	sll	a1,a1,0xc
    80001b22:	fffff097          	auipc	ra,0xfffff
    80001b26:	73c080e7          	jalr	1852(ra) # 8000125e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b2a:	4681                	li	a3,0
    80001b2c:	4605                	li	a2,1
    80001b2e:	020005b7          	lui	a1,0x2000
    80001b32:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b34:	05b6                	sll	a1,a1,0xd
    80001b36:	8526                	mv	a0,s1
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	726080e7          	jalr	1830(ra) # 8000125e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b40:	85ca                	mv	a1,s2
    80001b42:	8526                	mv	a0,s1
    80001b44:	00000097          	auipc	ra,0x0
    80001b48:	9e4080e7          	jalr	-1564(ra) # 80001528 <uvmfree>
}
    80001b4c:	60e2                	ld	ra,24(sp)
    80001b4e:	6442                	ld	s0,16(sp)
    80001b50:	64a2                	ld	s1,8(sp)
    80001b52:	6902                	ld	s2,0(sp)
    80001b54:	6105                	add	sp,sp,32
    80001b56:	8082                	ret

0000000080001b58 <freeproc>:
{
    80001b58:	1101                	add	sp,sp,-32
    80001b5a:	ec06                	sd	ra,24(sp)
    80001b5c:	e822                	sd	s0,16(sp)
    80001b5e:	e426                	sd	s1,8(sp)
    80001b60:	1000                	add	s0,sp,32
    80001b62:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b64:	6d28                	ld	a0,88(a0)
    80001b66:	c509                	beqz	a0,80001b70 <freeproc+0x18>
    kfree((void *)p->trapframe);
    80001b68:	fffff097          	auipc	ra,0xfffff
    80001b6c:	e7c080e7          	jalr	-388(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001b70:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b74:	68a8                	ld	a0,80(s1)
    80001b76:	c511                	beqz	a0,80001b82 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b78:	64ac                	ld	a1,72(s1)
    80001b7a:	00000097          	auipc	ra,0x0
    80001b7e:	f8c080e7          	jalr	-116(ra) # 80001b06 <proc_freepagetable>
  p->pagetable = 0;
    80001b82:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b86:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b8a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b8e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b92:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b96:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b9a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b9e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba2:	0004ac23          	sw	zero,24(s1)
}
    80001ba6:	60e2                	ld	ra,24(sp)
    80001ba8:	6442                	ld	s0,16(sp)
    80001baa:	64a2                	ld	s1,8(sp)
    80001bac:	6105                	add	sp,sp,32
    80001bae:	8082                	ret

0000000080001bb0 <allocproc>:
{
    80001bb0:	1101                	add	sp,sp,-32
    80001bb2:	ec06                	sd	ra,24(sp)
    80001bb4:	e822                	sd	s0,16(sp)
    80001bb6:	e426                	sd	s1,8(sp)
    80001bb8:	e04a                	sd	s2,0(sp)
    80001bba:	1000                	add	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++)
    80001bbc:	0000f497          	auipc	s1,0xf
    80001bc0:	3f448493          	add	s1,s1,1012 # 80010fb0 <proc>
    80001bc4:	00016917          	auipc	s2,0x16
    80001bc8:	9ec90913          	add	s2,s2,-1556 # 800175b0 <tickslock>
    acquire(&p->lock);
    80001bcc:	8526                	mv	a0,s1
    80001bce:	fffff097          	auipc	ra,0xfffff
    80001bd2:	004080e7          	jalr	4(ra) # 80000bd2 <acquire>
    if (p->state == UNUSED)
    80001bd6:	4c9c                	lw	a5,24(s1)
    80001bd8:	cf81                	beqz	a5,80001bf0 <allocproc+0x40>
      release(&p->lock);
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	0aa080e7          	jalr	170(ra) # 80000c86 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80001be4:	19848493          	add	s1,s1,408
    80001be8:	ff2492e3          	bne	s1,s2,80001bcc <allocproc+0x1c>
  return 0;
    80001bec:	4481                	li	s1,0
    80001bee:	a871                	j	80001c8a <allocproc+0xda>
  p->pid = allocpid();
    80001bf0:	00000097          	auipc	ra,0x0
    80001bf4:	e34080e7          	jalr	-460(ra) # 80001a24 <allocpid>
    80001bf8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bfa:	4785                	li	a5,1
    80001bfc:	cc9c                	sw	a5,24(s1)
  p->now_ticks = 0;
    80001bfe:	1804a223          	sw	zero,388(s1)
  p->sigalarm_status = 0;
    80001c02:	1804a823          	sw	zero,400(s1)
  p->interval = 0;
    80001c06:	1804a023          	sw	zero,384(s1)
  p->handler = -1;
    80001c0a:	57fd                	li	a5,-1
    80001c0c:	16f4bc23          	sd	a5,376(s1)
  p->alarm_trapframe = ((void*)0);
    80001c10:	1804b423          	sd	zero,392(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001c14:	fffff097          	auipc	ra,0xfffff
    80001c18:	ece080e7          	jalr	-306(ra) # 80000ae2 <kalloc>
    80001c1c:	892a                	mv	s2,a0
    80001c1e:	eca8                	sd	a0,88(s1)
    80001c20:	cd25                	beqz	a0,80001c98 <allocproc+0xe8>
  p->pagetable = proc_pagetable(p);
    80001c22:	8526                	mv	a0,s1
    80001c24:	00000097          	auipc	ra,0x0
    80001c28:	e46080e7          	jalr	-442(ra) # 80001a6a <proc_pagetable>
    80001c2c:	892a                	mv	s2,a0
    80001c2e:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0)
    80001c30:	c141                	beqz	a0,80001cb0 <allocproc+0x100>
  memset(&p->context, 0, sizeof(p->context));
    80001c32:	07000613          	li	a2,112
    80001c36:	4581                	li	a1,0
    80001c38:	06048513          	add	a0,s1,96
    80001c3c:	fffff097          	auipc	ra,0xfffff
    80001c40:	092080e7          	jalr	146(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c44:	00000797          	auipc	a5,0x0
    80001c48:	d9a78793          	add	a5,a5,-614 # 800019de <forkret>
    80001c4c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c4e:	60bc                	ld	a5,64(s1)
    80001c50:	6705                	lui	a4,0x1
    80001c52:	97ba                	add	a5,a5,a4
    80001c54:	f4bc                	sd	a5,104(s1)
  p->rtime = 0;
    80001c56:	1604a423          	sw	zero,360(s1)
  p->etime = 0;
    80001c5a:	1604a823          	sw	zero,368(s1)
  acquire(&tickslock);
    80001c5e:	00016517          	auipc	a0,0x16
    80001c62:	95250513          	add	a0,a0,-1710 # 800175b0 <tickslock>
    80001c66:	fffff097          	auipc	ra,0xfffff
    80001c6a:	f6c080e7          	jalr	-148(ra) # 80000bd2 <acquire>
  uint temp = ticks;
    80001c6e:	00007917          	auipc	s2,0x7
    80001c72:	ca292903          	lw	s2,-862(s2) # 80008910 <ticks>
  release(&tickslock);
    80001c76:	00016517          	auipc	a0,0x16
    80001c7a:	93a50513          	add	a0,a0,-1734 # 800175b0 <tickslock>
    80001c7e:	fffff097          	auipc	ra,0xfffff
    80001c82:	008080e7          	jalr	8(ra) # 80000c86 <release>
  p->ctime = temp;
    80001c86:	1724a623          	sw	s2,364(s1)
}
    80001c8a:	8526                	mv	a0,s1
    80001c8c:	60e2                	ld	ra,24(sp)
    80001c8e:	6442                	ld	s0,16(sp)
    80001c90:	64a2                	ld	s1,8(sp)
    80001c92:	6902                	ld	s2,0(sp)
    80001c94:	6105                	add	sp,sp,32
    80001c96:	8082                	ret
    freeproc(p);
    80001c98:	8526                	mv	a0,s1
    80001c9a:	00000097          	auipc	ra,0x0
    80001c9e:	ebe080e7          	jalr	-322(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001ca2:	8526                	mv	a0,s1
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	fe2080e7          	jalr	-30(ra) # 80000c86 <release>
    return 0;
    80001cac:	84ca                	mv	s1,s2
    80001cae:	bff1                	j	80001c8a <allocproc+0xda>
    freeproc(p);
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	00000097          	auipc	ra,0x0
    80001cb6:	ea6080e7          	jalr	-346(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001cba:	8526                	mv	a0,s1
    80001cbc:	fffff097          	auipc	ra,0xfffff
    80001cc0:	fca080e7          	jalr	-54(ra) # 80000c86 <release>
    return 0;
    80001cc4:	84ca                	mv	s1,s2
    80001cc6:	b7d1                	j	80001c8a <allocproc+0xda>

0000000080001cc8 <userinit>:
{
    80001cc8:	1101                	add	sp,sp,-32
    80001cca:	ec06                	sd	ra,24(sp)
    80001ccc:	e822                	sd	s0,16(sp)
    80001cce:	e426                	sd	s1,8(sp)
    80001cd0:	1000                	add	s0,sp,32
  p = allocproc();
    80001cd2:	00000097          	auipc	ra,0x0
    80001cd6:	ede080e7          	jalr	-290(ra) # 80001bb0 <allocproc>
    80001cda:	84aa                	mv	s1,a0
  initproc = p;
    80001cdc:	00007797          	auipc	a5,0x7
    80001ce0:	c2a7b623          	sd	a0,-980(a5) # 80008908 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ce4:	03400613          	li	a2,52
    80001ce8:	00007597          	auipc	a1,0x7
    80001cec:	b9858593          	add	a1,a1,-1128 # 80008880 <initcode>
    80001cf0:	6928                	ld	a0,80(a0)
    80001cf2:	fffff097          	auipc	ra,0xfffff
    80001cf6:	65e080e7          	jalr	1630(ra) # 80001350 <uvmfirst>
  p->sz = PGSIZE;
    80001cfa:	6785                	lui	a5,0x1
    80001cfc:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;     // user program counter
    80001cfe:	6cb8                	ld	a4,88(s1)
    80001d00:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE; // user stack pointer
    80001d04:	6cb8                	ld	a4,88(s1)
    80001d06:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d08:	4641                	li	a2,16
    80001d0a:	00006597          	auipc	a1,0x6
    80001d0e:	4f658593          	add	a1,a1,1270 # 80008200 <digits+0x1c0>
    80001d12:	15848513          	add	a0,s1,344
    80001d16:	fffff097          	auipc	ra,0xfffff
    80001d1a:	100080e7          	jalr	256(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001d1e:	00006517          	auipc	a0,0x6
    80001d22:	4f250513          	add	a0,a0,1266 # 80008210 <digits+0x1d0>
    80001d26:	00002097          	auipc	ra,0x2
    80001d2a:	4c8080e7          	jalr	1224(ra) # 800041ee <namei>
    80001d2e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d32:	478d                	li	a5,3
    80001d34:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d36:	8526                	mv	a0,s1
    80001d38:	fffff097          	auipc	ra,0xfffff
    80001d3c:	f4e080e7          	jalr	-178(ra) # 80000c86 <release>
}
    80001d40:	60e2                	ld	ra,24(sp)
    80001d42:	6442                	ld	s0,16(sp)
    80001d44:	64a2                	ld	s1,8(sp)
    80001d46:	6105                	add	sp,sp,32
    80001d48:	8082                	ret

0000000080001d4a <growproc>:
{
    80001d4a:	1101                	add	sp,sp,-32
    80001d4c:	ec06                	sd	ra,24(sp)
    80001d4e:	e822                	sd	s0,16(sp)
    80001d50:	e426                	sd	s1,8(sp)
    80001d52:	e04a                	sd	s2,0(sp)
    80001d54:	1000                	add	s0,sp,32
    80001d56:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d58:	00000097          	auipc	ra,0x0
    80001d5c:	c4e080e7          	jalr	-946(ra) # 800019a6 <myproc>
    80001d60:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d62:	652c                	ld	a1,72(a0)
  if (n > 0)
    80001d64:	01204c63          	bgtz	s2,80001d7c <growproc+0x32>
  else if (n < 0)
    80001d68:	02094663          	bltz	s2,80001d94 <growproc+0x4a>
  p->sz = sz;
    80001d6c:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d6e:	4501                	li	a0,0
}
    80001d70:	60e2                	ld	ra,24(sp)
    80001d72:	6442                	ld	s0,16(sp)
    80001d74:	64a2                	ld	s1,8(sp)
    80001d76:	6902                	ld	s2,0(sp)
    80001d78:	6105                	add	sp,sp,32
    80001d7a:	8082                	ret
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001d7c:	4691                	li	a3,4
    80001d7e:	00b90633          	add	a2,s2,a1
    80001d82:	6928                	ld	a0,80(a0)
    80001d84:	fffff097          	auipc	ra,0xfffff
    80001d88:	686080e7          	jalr	1670(ra) # 8000140a <uvmalloc>
    80001d8c:	85aa                	mv	a1,a0
    80001d8e:	fd79                	bnez	a0,80001d6c <growproc+0x22>
      return -1;
    80001d90:	557d                	li	a0,-1
    80001d92:	bff9                	j	80001d70 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d94:	00b90633          	add	a2,s2,a1
    80001d98:	6928                	ld	a0,80(a0)
    80001d9a:	fffff097          	auipc	ra,0xfffff
    80001d9e:	628080e7          	jalr	1576(ra) # 800013c2 <uvmdealloc>
    80001da2:	85aa                	mv	a1,a0
    80001da4:	b7e1                	j	80001d6c <growproc+0x22>

0000000080001da6 <fork>:
{
    80001da6:	7139                	add	sp,sp,-64
    80001da8:	fc06                	sd	ra,56(sp)
    80001daa:	f822                	sd	s0,48(sp)
    80001dac:	f426                	sd	s1,40(sp)
    80001dae:	f04a                	sd	s2,32(sp)
    80001db0:	ec4e                	sd	s3,24(sp)
    80001db2:	e852                	sd	s4,16(sp)
    80001db4:	e456                	sd	s5,8(sp)
    80001db6:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001db8:	00000097          	auipc	ra,0x0
    80001dbc:	bee080e7          	jalr	-1042(ra) # 800019a6 <myproc>
    80001dc0:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0)
    80001dc2:	00000097          	auipc	ra,0x0
    80001dc6:	dee080e7          	jalr	-530(ra) # 80001bb0 <allocproc>
    80001dca:	10050c63          	beqz	a0,80001ee2 <fork+0x13c>
    80001dce:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80001dd0:	048ab603          	ld	a2,72(s5)
    80001dd4:	692c                	ld	a1,80(a0)
    80001dd6:	050ab503          	ld	a0,80(s5)
    80001dda:	fffff097          	auipc	ra,0xfffff
    80001dde:	788080e7          	jalr	1928(ra) # 80001562 <uvmcopy>
    80001de2:	04054863          	bltz	a0,80001e32 <fork+0x8c>
  np->sz = p->sz;
    80001de6:	048ab783          	ld	a5,72(s5)
    80001dea:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001dee:	058ab683          	ld	a3,88(s5)
    80001df2:	87b6                	mv	a5,a3
    80001df4:	058a3703          	ld	a4,88(s4)
    80001df8:	12068693          	add	a3,a3,288
    80001dfc:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e00:	6788                	ld	a0,8(a5)
    80001e02:	6b8c                	ld	a1,16(a5)
    80001e04:	6f90                	ld	a2,24(a5)
    80001e06:	01073023          	sd	a6,0(a4)
    80001e0a:	e708                	sd	a0,8(a4)
    80001e0c:	eb0c                	sd	a1,16(a4)
    80001e0e:	ef10                	sd	a2,24(a4)
    80001e10:	02078793          	add	a5,a5,32
    80001e14:	02070713          	add	a4,a4,32
    80001e18:	fed792e3          	bne	a5,a3,80001dfc <fork+0x56>
  np->trapframe->a0 = 0;
    80001e1c:	058a3783          	ld	a5,88(s4)
    80001e20:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001e24:	0d0a8493          	add	s1,s5,208
    80001e28:	0d0a0913          	add	s2,s4,208
    80001e2c:	150a8993          	add	s3,s5,336
    80001e30:	a00d                	j	80001e52 <fork+0xac>
    freeproc(np);
    80001e32:	8552                	mv	a0,s4
    80001e34:	00000097          	auipc	ra,0x0
    80001e38:	d24080e7          	jalr	-732(ra) # 80001b58 <freeproc>
    release(&np->lock);
    80001e3c:	8552                	mv	a0,s4
    80001e3e:	fffff097          	auipc	ra,0xfffff
    80001e42:	e48080e7          	jalr	-440(ra) # 80000c86 <release>
    return -1;
    80001e46:	597d                	li	s2,-1
    80001e48:	a059                	j	80001ece <fork+0x128>
  for (i = 0; i < NOFILE; i++)
    80001e4a:	04a1                	add	s1,s1,8
    80001e4c:	0921                	add	s2,s2,8
    80001e4e:	01348b63          	beq	s1,s3,80001e64 <fork+0xbe>
    if (p->ofile[i])
    80001e52:	6088                	ld	a0,0(s1)
    80001e54:	d97d                	beqz	a0,80001e4a <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e56:	00003097          	auipc	ra,0x3
    80001e5a:	a22080e7          	jalr	-1502(ra) # 80004878 <filedup>
    80001e5e:	00a93023          	sd	a0,0(s2)
    80001e62:	b7e5                	j	80001e4a <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e64:	150ab503          	ld	a0,336(s5)
    80001e68:	00002097          	auipc	ra,0x2
    80001e6c:	ba2080e7          	jalr	-1118(ra) # 80003a0a <idup>
    80001e70:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e74:	4641                	li	a2,16
    80001e76:	158a8593          	add	a1,s5,344
    80001e7a:	158a0513          	add	a0,s4,344
    80001e7e:	fffff097          	auipc	ra,0xfffff
    80001e82:	f98080e7          	jalr	-104(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e86:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e8a:	8552                	mv	a0,s4
    80001e8c:	fffff097          	auipc	ra,0xfffff
    80001e90:	dfa080e7          	jalr	-518(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001e94:	0000f497          	auipc	s1,0xf
    80001e98:	d0448493          	add	s1,s1,-764 # 80010b98 <wait_lock>
    80001e9c:	8526                	mv	a0,s1
    80001e9e:	fffff097          	auipc	ra,0xfffff
    80001ea2:	d34080e7          	jalr	-716(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001ea6:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001eaa:	8526                	mv	a0,s1
    80001eac:	fffff097          	auipc	ra,0xfffff
    80001eb0:	dda080e7          	jalr	-550(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001eb4:	8552                	mv	a0,s4
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	d1c080e7          	jalr	-740(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001ebe:	478d                	li	a5,3
    80001ec0:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001ec4:	8552                	mv	a0,s4
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	dc0080e7          	jalr	-576(ra) # 80000c86 <release>
}
    80001ece:	854a                	mv	a0,s2
    80001ed0:	70e2                	ld	ra,56(sp)
    80001ed2:	7442                	ld	s0,48(sp)
    80001ed4:	74a2                	ld	s1,40(sp)
    80001ed6:	7902                	ld	s2,32(sp)
    80001ed8:	69e2                	ld	s3,24(sp)
    80001eda:	6a42                	ld	s4,16(sp)
    80001edc:	6aa2                	ld	s5,8(sp)
    80001ede:	6121                	add	sp,sp,64
    80001ee0:	8082                	ret
    return -1;
    80001ee2:	597d                	li	s2,-1
    80001ee4:	b7ed                	j	80001ece <fork+0x128>

0000000080001ee6 <scheduler>:
{
    80001ee6:	715d                	add	sp,sp,-80
    80001ee8:	e486                	sd	ra,72(sp)
    80001eea:	e0a2                	sd	s0,64(sp)
    80001eec:	fc26                	sd	s1,56(sp)
    80001eee:	f84a                	sd	s2,48(sp)
    80001ef0:	f44e                	sd	s3,40(sp)
    80001ef2:	f052                	sd	s4,32(sp)
    80001ef4:	ec56                	sd	s5,24(sp)
    80001ef6:	e85a                	sd	s6,16(sp)
    80001ef8:	e45e                	sd	s7,8(sp)
    80001efa:	0880                	add	s0,sp,80
    80001efc:	8792                	mv	a5,tp
  int id = r_tp();
    80001efe:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f00:	00779b13          	sll	s6,a5,0x7
    80001f04:	0000f717          	auipc	a4,0xf
    80001f08:	c7c70713          	add	a4,a4,-900 # 80010b80 <pid_lock>
    80001f0c:	975a                	add	a4,a4,s6
    80001f0e:	02073823          	sd	zero,48(a4)
      swtch(&c->context, &p->context);
    80001f12:	0000f717          	auipc	a4,0xf
    80001f16:	ca670713          	add	a4,a4,-858 # 80010bb8 <cpus+0x8>
    80001f1a:	9b3a                	add	s6,s6,a4
      if (p->state == RUNNABLE)
    80001f1c:	4a0d                	li	s4,3
    for (p = proc; p < &proc[NPROC]; p++)
    80001f1e:	00015997          	auipc	s3,0x15
    80001f22:	69298993          	add	s3,s3,1682 # 800175b0 <tickslock>
      p->state = RUNNING;
    80001f26:	4b91                	li	s7,4
      c->proc = p;
    80001f28:	079e                	sll	a5,a5,0x7
    80001f2a:	0000fa97          	auipc	s5,0xf
    80001f2e:	c56a8a93          	add	s5,s5,-938 # 80010b80 <pid_lock>
    80001f32:	9abe                	add	s5,s5,a5
    80001f34:	a895                	j	80001fa8 <scheduler+0xc2>
    for (p++; p < &proc[NPROC]; p++)
    80001f36:	19890493          	add	s1,s2,408
    80001f3a:	0134e763          	bltu	s1,s3,80001f48 <scheduler+0x62>
    80001f3e:	a869                	j	80001fd8 <scheduler+0xf2>
    80001f40:	19848493          	add	s1,s1,408
    80001f44:	0934fa63          	bgeu	s1,s3,80001fd8 <scheduler+0xf2>
      acquire(&p->lock);
    80001f48:	8526                	mv	a0,s1
    80001f4a:	fffff097          	auipc	ra,0xfffff
    80001f4e:	c88080e7          	jalr	-888(ra) # 80000bd2 <acquire>
      if (p->state == RUNNABLE && next_process->ctime > p->ctime)
    80001f52:	4c9c                	lw	a5,24(s1)
    80001f54:	ff4796e3          	bne	a5,s4,80001f40 <scheduler+0x5a>
    80001f58:	16c92703          	lw	a4,364(s2)
    80001f5c:	16c4a783          	lw	a5,364(s1)
    80001f60:	fee7f0e3          	bgeu	a5,a4,80001f40 <scheduler+0x5a>
    80001f64:	8926                	mv	s2,s1
    80001f66:	bfe9                	j	80001f40 <scheduler+0x5a>
        release(&p->lock);
    80001f68:	8526                	mv	a0,s1
    80001f6a:	fffff097          	auipc	ra,0xfffff
    80001f6e:	d1c080e7          	jalr	-740(ra) # 80000c86 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001f72:	19848493          	add	s1,s1,408
    80001f76:	01348563          	beq	s1,s3,80001f80 <scheduler+0x9a>
      if (p != next_process)
    80001f7a:	ff2497e3          	bne	s1,s2,80001f68 <scheduler+0x82>
    80001f7e:	bfd5                	j	80001f72 <scheduler+0x8c>
    if (next_process != 0)
    80001f80:	02090463          	beqz	s2,80001fa8 <scheduler+0xc2>
      p->state = RUNNING;
    80001f84:	01792c23          	sw	s7,24(s2)
      c->proc = p;
    80001f88:	032ab823          	sd	s2,48(s5)
      swtch(&c->context, &p->context);
    80001f8c:	06090593          	add	a1,s2,96
    80001f90:	855a                	mv	a0,s6
    80001f92:	00001097          	auipc	ra,0x1
    80001f96:	87c080e7          	jalr	-1924(ra) # 8000280e <swtch>
      c->proc = 0;
    80001f9a:	020ab823          	sd	zero,48(s5)
      release(&p->lock);
    80001f9e:	854a                	mv	a0,s2
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	ce6080e7          	jalr	-794(ra) # 80000c86 <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fa8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fac:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fb0:	10079073          	csrw	sstatus,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80001fb4:	0000f917          	auipc	s2,0xf
    80001fb8:	ffc90913          	add	s2,s2,-4 # 80010fb0 <proc>
      acquire(&p->lock);
    80001fbc:	854a                	mv	a0,s2
    80001fbe:	fffff097          	auipc	ra,0xfffff
    80001fc2:	c14080e7          	jalr	-1004(ra) # 80000bd2 <acquire>
      if (p->state == RUNNABLE)
    80001fc6:	01892783          	lw	a5,24(s2)
    80001fca:	f74786e3          	beq	a5,s4,80001f36 <scheduler+0x50>
    for (p = proc; p < &proc[NPROC]; p++)
    80001fce:	19890913          	add	s2,s2,408
    80001fd2:	ff3915e3          	bne	s2,s3,80001fbc <scheduler+0xd6>
    struct proc *next_process = 0;
    80001fd6:	4901                	li	s2,0
    for (p = proc; p < &proc[NPROC]; p++)
    80001fd8:	0000f497          	auipc	s1,0xf
    80001fdc:	fd848493          	add	s1,s1,-40 # 80010fb0 <proc>
    80001fe0:	bf69                	j	80001f7a <scheduler+0x94>

0000000080001fe2 <sched>:
{
    80001fe2:	7179                	add	sp,sp,-48
    80001fe4:	f406                	sd	ra,40(sp)
    80001fe6:	f022                	sd	s0,32(sp)
    80001fe8:	ec26                	sd	s1,24(sp)
    80001fea:	e84a                	sd	s2,16(sp)
    80001fec:	e44e                	sd	s3,8(sp)
    80001fee:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    80001ff0:	00000097          	auipc	ra,0x0
    80001ff4:	9b6080e7          	jalr	-1610(ra) # 800019a6 <myproc>
    80001ff8:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001ffa:	fffff097          	auipc	ra,0xfffff
    80001ffe:	b5e080e7          	jalr	-1186(ra) # 80000b58 <holding>
    80002002:	c93d                	beqz	a0,80002078 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002004:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002006:	2781                	sext.w	a5,a5
    80002008:	079e                	sll	a5,a5,0x7
    8000200a:	0000f717          	auipc	a4,0xf
    8000200e:	b7670713          	add	a4,a4,-1162 # 80010b80 <pid_lock>
    80002012:	97ba                	add	a5,a5,a4
    80002014:	0a87a703          	lw	a4,168(a5)
    80002018:	4785                	li	a5,1
    8000201a:	06f71763          	bne	a4,a5,80002088 <sched+0xa6>
  if (p->state == RUNNING)
    8000201e:	4c98                	lw	a4,24(s1)
    80002020:	4791                	li	a5,4
    80002022:	06f70b63          	beq	a4,a5,80002098 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002026:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000202a:	8b89                	and	a5,a5,2
  if (intr_get())
    8000202c:	efb5                	bnez	a5,800020a8 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000202e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002030:	0000f917          	auipc	s2,0xf
    80002034:	b5090913          	add	s2,s2,-1200 # 80010b80 <pid_lock>
    80002038:	2781                	sext.w	a5,a5
    8000203a:	079e                	sll	a5,a5,0x7
    8000203c:	97ca                	add	a5,a5,s2
    8000203e:	0ac7a983          	lw	s3,172(a5)
    80002042:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002044:	2781                	sext.w	a5,a5
    80002046:	079e                	sll	a5,a5,0x7
    80002048:	0000f597          	auipc	a1,0xf
    8000204c:	b7058593          	add	a1,a1,-1168 # 80010bb8 <cpus+0x8>
    80002050:	95be                	add	a1,a1,a5
    80002052:	06048513          	add	a0,s1,96
    80002056:	00000097          	auipc	ra,0x0
    8000205a:	7b8080e7          	jalr	1976(ra) # 8000280e <swtch>
    8000205e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002060:	2781                	sext.w	a5,a5
    80002062:	079e                	sll	a5,a5,0x7
    80002064:	993e                	add	s2,s2,a5
    80002066:	0b392623          	sw	s3,172(s2)
}
    8000206a:	70a2                	ld	ra,40(sp)
    8000206c:	7402                	ld	s0,32(sp)
    8000206e:	64e2                	ld	s1,24(sp)
    80002070:	6942                	ld	s2,16(sp)
    80002072:	69a2                	ld	s3,8(sp)
    80002074:	6145                	add	sp,sp,48
    80002076:	8082                	ret
    panic("sched p->lock");
    80002078:	00006517          	auipc	a0,0x6
    8000207c:	1a050513          	add	a0,a0,416 # 80008218 <digits+0x1d8>
    80002080:	ffffe097          	auipc	ra,0xffffe
    80002084:	4bc080e7          	jalr	1212(ra) # 8000053c <panic>
    panic("sched locks");
    80002088:	00006517          	auipc	a0,0x6
    8000208c:	1a050513          	add	a0,a0,416 # 80008228 <digits+0x1e8>
    80002090:	ffffe097          	auipc	ra,0xffffe
    80002094:	4ac080e7          	jalr	1196(ra) # 8000053c <panic>
    panic("sched running");
    80002098:	00006517          	auipc	a0,0x6
    8000209c:	1a050513          	add	a0,a0,416 # 80008238 <digits+0x1f8>
    800020a0:	ffffe097          	auipc	ra,0xffffe
    800020a4:	49c080e7          	jalr	1180(ra) # 8000053c <panic>
    panic("sched interruptible");
    800020a8:	00006517          	auipc	a0,0x6
    800020ac:	1a050513          	add	a0,a0,416 # 80008248 <digits+0x208>
    800020b0:	ffffe097          	auipc	ra,0xffffe
    800020b4:	48c080e7          	jalr	1164(ra) # 8000053c <panic>

00000000800020b8 <yield>:
{
    800020b8:	1101                	add	sp,sp,-32
    800020ba:	ec06                	sd	ra,24(sp)
    800020bc:	e822                	sd	s0,16(sp)
    800020be:	e426                	sd	s1,8(sp)
    800020c0:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    800020c2:	00000097          	auipc	ra,0x0
    800020c6:	8e4080e7          	jalr	-1820(ra) # 800019a6 <myproc>
    800020ca:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020cc:	fffff097          	auipc	ra,0xfffff
    800020d0:	b06080e7          	jalr	-1274(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    800020d4:	478d                	li	a5,3
    800020d6:	cc9c                	sw	a5,24(s1)
  sched();
    800020d8:	00000097          	auipc	ra,0x0
    800020dc:	f0a080e7          	jalr	-246(ra) # 80001fe2 <sched>
  release(&p->lock);
    800020e0:	8526                	mv	a0,s1
    800020e2:	fffff097          	auipc	ra,0xfffff
    800020e6:	ba4080e7          	jalr	-1116(ra) # 80000c86 <release>
}
    800020ea:	60e2                	ld	ra,24(sp)
    800020ec:	6442                	ld	s0,16(sp)
    800020ee:	64a2                	ld	s1,8(sp)
    800020f0:	6105                	add	sp,sp,32
    800020f2:	8082                	ret

00000000800020f4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800020f4:	7179                	add	sp,sp,-48
    800020f6:	f406                	sd	ra,40(sp)
    800020f8:	f022                	sd	s0,32(sp)
    800020fa:	ec26                	sd	s1,24(sp)
    800020fc:	e84a                	sd	s2,16(sp)
    800020fe:	e44e                	sd	s3,8(sp)
    80002100:	1800                	add	s0,sp,48
    80002102:	89aa                	mv	s3,a0
    80002104:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002106:	00000097          	auipc	ra,0x0
    8000210a:	8a0080e7          	jalr	-1888(ra) # 800019a6 <myproc>
    8000210e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002110:	fffff097          	auipc	ra,0xfffff
    80002114:	ac2080e7          	jalr	-1342(ra) # 80000bd2 <acquire>
  release(lk);
    80002118:	854a                	mv	a0,s2
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	b6c080e7          	jalr	-1172(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    80002122:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002126:	4789                	li	a5,2
    80002128:	cc9c                	sw	a5,24(s1)

  sched();
    8000212a:	00000097          	auipc	ra,0x0
    8000212e:	eb8080e7          	jalr	-328(ra) # 80001fe2 <sched>

  // Tidy up.
  p->chan = 0;
    80002132:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002136:	8526                	mv	a0,s1
    80002138:	fffff097          	auipc	ra,0xfffff
    8000213c:	b4e080e7          	jalr	-1202(ra) # 80000c86 <release>
  acquire(lk);
    80002140:	854a                	mv	a0,s2
    80002142:	fffff097          	auipc	ra,0xfffff
    80002146:	a90080e7          	jalr	-1392(ra) # 80000bd2 <acquire>
}
    8000214a:	70a2                	ld	ra,40(sp)
    8000214c:	7402                	ld	s0,32(sp)
    8000214e:	64e2                	ld	s1,24(sp)
    80002150:	6942                	ld	s2,16(sp)
    80002152:	69a2                	ld	s3,8(sp)
    80002154:	6145                	add	sp,sp,48
    80002156:	8082                	ret

0000000080002158 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002158:	7139                	add	sp,sp,-64
    8000215a:	fc06                	sd	ra,56(sp)
    8000215c:	f822                	sd	s0,48(sp)
    8000215e:	f426                	sd	s1,40(sp)
    80002160:	f04a                	sd	s2,32(sp)
    80002162:	ec4e                	sd	s3,24(sp)
    80002164:	e852                	sd	s4,16(sp)
    80002166:	e456                	sd	s5,8(sp)
    80002168:	0080                	add	s0,sp,64
    8000216a:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000216c:	0000f497          	auipc	s1,0xf
    80002170:	e4448493          	add	s1,s1,-444 # 80010fb0 <proc>
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
    80002174:	4989                	li	s3,2
      {
        p->state = RUNNABLE;
    80002176:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++)
    80002178:	00015917          	auipc	s2,0x15
    8000217c:	43890913          	add	s2,s2,1080 # 800175b0 <tickslock>
    80002180:	a811                	j	80002194 <wakeup+0x3c>
      }
      release(&p->lock);
    80002182:	8526                	mv	a0,s1
    80002184:	fffff097          	auipc	ra,0xfffff
    80002188:	b02080e7          	jalr	-1278(ra) # 80000c86 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    8000218c:	19848493          	add	s1,s1,408
    80002190:	03248663          	beq	s1,s2,800021bc <wakeup+0x64>
    if (p != myproc())
    80002194:	00000097          	auipc	ra,0x0
    80002198:	812080e7          	jalr	-2030(ra) # 800019a6 <myproc>
    8000219c:	fea488e3          	beq	s1,a0,8000218c <wakeup+0x34>
      acquire(&p->lock);
    800021a0:	8526                	mv	a0,s1
    800021a2:	fffff097          	auipc	ra,0xfffff
    800021a6:	a30080e7          	jalr	-1488(ra) # 80000bd2 <acquire>
      if (p->state == SLEEPING && p->chan == chan)
    800021aa:	4c9c                	lw	a5,24(s1)
    800021ac:	fd379be3          	bne	a5,s3,80002182 <wakeup+0x2a>
    800021b0:	709c                	ld	a5,32(s1)
    800021b2:	fd4798e3          	bne	a5,s4,80002182 <wakeup+0x2a>
        p->state = RUNNABLE;
    800021b6:	0154ac23          	sw	s5,24(s1)
    800021ba:	b7e1                	j	80002182 <wakeup+0x2a>
    }
  }
}
    800021bc:	70e2                	ld	ra,56(sp)
    800021be:	7442                	ld	s0,48(sp)
    800021c0:	74a2                	ld	s1,40(sp)
    800021c2:	7902                	ld	s2,32(sp)
    800021c4:	69e2                	ld	s3,24(sp)
    800021c6:	6a42                	ld	s4,16(sp)
    800021c8:	6aa2                	ld	s5,8(sp)
    800021ca:	6121                	add	sp,sp,64
    800021cc:	8082                	ret

00000000800021ce <reparent>:
{
    800021ce:	7179                	add	sp,sp,-48
    800021d0:	f406                	sd	ra,40(sp)
    800021d2:	f022                	sd	s0,32(sp)
    800021d4:	ec26                	sd	s1,24(sp)
    800021d6:	e84a                	sd	s2,16(sp)
    800021d8:	e44e                	sd	s3,8(sp)
    800021da:	e052                	sd	s4,0(sp)
    800021dc:	1800                	add	s0,sp,48
    800021de:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800021e0:	0000f497          	auipc	s1,0xf
    800021e4:	dd048493          	add	s1,s1,-560 # 80010fb0 <proc>
      pp->parent = initproc;
    800021e8:	00006a17          	auipc	s4,0x6
    800021ec:	720a0a13          	add	s4,s4,1824 # 80008908 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++)
    800021f0:	00015997          	auipc	s3,0x15
    800021f4:	3c098993          	add	s3,s3,960 # 800175b0 <tickslock>
    800021f8:	a029                	j	80002202 <reparent+0x34>
    800021fa:	19848493          	add	s1,s1,408
    800021fe:	01348d63          	beq	s1,s3,80002218 <reparent+0x4a>
    if (pp->parent == p)
    80002202:	7c9c                	ld	a5,56(s1)
    80002204:	ff279be3          	bne	a5,s2,800021fa <reparent+0x2c>
      pp->parent = initproc;
    80002208:	000a3503          	ld	a0,0(s4)
    8000220c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000220e:	00000097          	auipc	ra,0x0
    80002212:	f4a080e7          	jalr	-182(ra) # 80002158 <wakeup>
    80002216:	b7d5                	j	800021fa <reparent+0x2c>
}
    80002218:	70a2                	ld	ra,40(sp)
    8000221a:	7402                	ld	s0,32(sp)
    8000221c:	64e2                	ld	s1,24(sp)
    8000221e:	6942                	ld	s2,16(sp)
    80002220:	69a2                	ld	s3,8(sp)
    80002222:	6a02                	ld	s4,0(sp)
    80002224:	6145                	add	sp,sp,48
    80002226:	8082                	ret

0000000080002228 <exit>:
{
    80002228:	7179                	add	sp,sp,-48
    8000222a:	f406                	sd	ra,40(sp)
    8000222c:	f022                	sd	s0,32(sp)
    8000222e:	ec26                	sd	s1,24(sp)
    80002230:	e84a                	sd	s2,16(sp)
    80002232:	e44e                	sd	s3,8(sp)
    80002234:	e052                	sd	s4,0(sp)
    80002236:	1800                	add	s0,sp,48
    80002238:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000223a:	fffff097          	auipc	ra,0xfffff
    8000223e:	76c080e7          	jalr	1900(ra) # 800019a6 <myproc>
    80002242:	89aa                	mv	s3,a0
  if (p == initproc)
    80002244:	00006797          	auipc	a5,0x6
    80002248:	6c47b783          	ld	a5,1732(a5) # 80008908 <initproc>
    8000224c:	0d050493          	add	s1,a0,208
    80002250:	15050913          	add	s2,a0,336
    80002254:	02a79363          	bne	a5,a0,8000227a <exit+0x52>
    panic("init exiting");
    80002258:	00006517          	auipc	a0,0x6
    8000225c:	00850513          	add	a0,a0,8 # 80008260 <digits+0x220>
    80002260:	ffffe097          	auipc	ra,0xffffe
    80002264:	2dc080e7          	jalr	732(ra) # 8000053c <panic>
      fileclose(f);
    80002268:	00002097          	auipc	ra,0x2
    8000226c:	662080e7          	jalr	1634(ra) # 800048ca <fileclose>
      p->ofile[fd] = 0;
    80002270:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++)
    80002274:	04a1                	add	s1,s1,8
    80002276:	01248563          	beq	s1,s2,80002280 <exit+0x58>
    if (p->ofile[fd])
    8000227a:	6088                	ld	a0,0(s1)
    8000227c:	f575                	bnez	a0,80002268 <exit+0x40>
    8000227e:	bfdd                	j	80002274 <exit+0x4c>
  begin_op();
    80002280:	00002097          	auipc	ra,0x2
    80002284:	16e080e7          	jalr	366(ra) # 800043ee <begin_op>
  iput(p->cwd);
    80002288:	1509b503          	ld	a0,336(s3)
    8000228c:	00002097          	auipc	ra,0x2
    80002290:	976080e7          	jalr	-1674(ra) # 80003c02 <iput>
  end_op();
    80002294:	00002097          	auipc	ra,0x2
    80002298:	1d4080e7          	jalr	468(ra) # 80004468 <end_op>
  p->cwd = 0;
    8000229c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022a0:	0000f497          	auipc	s1,0xf
    800022a4:	8f848493          	add	s1,s1,-1800 # 80010b98 <wait_lock>
    800022a8:	8526                	mv	a0,s1
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	928080e7          	jalr	-1752(ra) # 80000bd2 <acquire>
  reparent(p);
    800022b2:	854e                	mv	a0,s3
    800022b4:	00000097          	auipc	ra,0x0
    800022b8:	f1a080e7          	jalr	-230(ra) # 800021ce <reparent>
  wakeup(p->parent);
    800022bc:	0389b503          	ld	a0,56(s3)
    800022c0:	00000097          	auipc	ra,0x0
    800022c4:	e98080e7          	jalr	-360(ra) # 80002158 <wakeup>
  acquire(&p->lock);
    800022c8:	854e                	mv	a0,s3
    800022ca:	fffff097          	auipc	ra,0xfffff
    800022ce:	908080e7          	jalr	-1784(ra) # 80000bd2 <acquire>
  p->xstate = status;
    800022d2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022d6:	4795                	li	a5,5
    800022d8:	00f9ac23          	sw	a5,24(s3)
  p->etime = ticks;
    800022dc:	00006797          	auipc	a5,0x6
    800022e0:	6347a783          	lw	a5,1588(a5) # 80008910 <ticks>
    800022e4:	16f9a823          	sw	a5,368(s3)
  release(&wait_lock);
    800022e8:	8526                	mv	a0,s1
    800022ea:	fffff097          	auipc	ra,0xfffff
    800022ee:	99c080e7          	jalr	-1636(ra) # 80000c86 <release>
  sched();
    800022f2:	00000097          	auipc	ra,0x0
    800022f6:	cf0080e7          	jalr	-784(ra) # 80001fe2 <sched>
  panic("zombie exit");
    800022fa:	00006517          	auipc	a0,0x6
    800022fe:	f7650513          	add	a0,a0,-138 # 80008270 <digits+0x230>
    80002302:	ffffe097          	auipc	ra,0xffffe
    80002306:	23a080e7          	jalr	570(ra) # 8000053c <panic>

000000008000230a <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    8000230a:	7179                	add	sp,sp,-48
    8000230c:	f406                	sd	ra,40(sp)
    8000230e:	f022                	sd	s0,32(sp)
    80002310:	ec26                	sd	s1,24(sp)
    80002312:	e84a                	sd	s2,16(sp)
    80002314:	e44e                	sd	s3,8(sp)
    80002316:	1800                	add	s0,sp,48
    80002318:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
    8000231a:	0000f497          	auipc	s1,0xf
    8000231e:	c9648493          	add	s1,s1,-874 # 80010fb0 <proc>
    80002322:	00015997          	auipc	s3,0x15
    80002326:	28e98993          	add	s3,s3,654 # 800175b0 <tickslock>
  {
    acquire(&p->lock);
    8000232a:	8526                	mv	a0,s1
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	8a6080e7          	jalr	-1882(ra) # 80000bd2 <acquire>
    if (p->pid == pid)
    80002334:	589c                	lw	a5,48(s1)
    80002336:	01278d63          	beq	a5,s2,80002350 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000233a:	8526                	mv	a0,s1
    8000233c:	fffff097          	auipc	ra,0xfffff
    80002340:	94a080e7          	jalr	-1718(ra) # 80000c86 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    80002344:	19848493          	add	s1,s1,408
    80002348:	ff3491e3          	bne	s1,s3,8000232a <kill+0x20>
  }
  return -1;
    8000234c:	557d                	li	a0,-1
    8000234e:	a829                	j	80002368 <kill+0x5e>
      p->killed = 1;
    80002350:	4785                	li	a5,1
    80002352:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING)
    80002354:	4c98                	lw	a4,24(s1)
    80002356:	4789                	li	a5,2
    80002358:	00f70f63          	beq	a4,a5,80002376 <kill+0x6c>
      release(&p->lock);
    8000235c:	8526                	mv	a0,s1
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	928080e7          	jalr	-1752(ra) # 80000c86 <release>
      return 0;
    80002366:	4501                	li	a0,0
}
    80002368:	70a2                	ld	ra,40(sp)
    8000236a:	7402                	ld	s0,32(sp)
    8000236c:	64e2                	ld	s1,24(sp)
    8000236e:	6942                	ld	s2,16(sp)
    80002370:	69a2                	ld	s3,8(sp)
    80002372:	6145                	add	sp,sp,48
    80002374:	8082                	ret
        p->state = RUNNABLE;
    80002376:	478d                	li	a5,3
    80002378:	cc9c                	sw	a5,24(s1)
    8000237a:	b7cd                	j	8000235c <kill+0x52>

000000008000237c <setkilled>:

void setkilled(struct proc *p)
{
    8000237c:	1101                	add	sp,sp,-32
    8000237e:	ec06                	sd	ra,24(sp)
    80002380:	e822                	sd	s0,16(sp)
    80002382:	e426                	sd	s1,8(sp)
    80002384:	1000                	add	s0,sp,32
    80002386:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	84a080e7          	jalr	-1974(ra) # 80000bd2 <acquire>
  p->killed = 1;
    80002390:	4785                	li	a5,1
    80002392:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002394:	8526                	mv	a0,s1
    80002396:	fffff097          	auipc	ra,0xfffff
    8000239a:	8f0080e7          	jalr	-1808(ra) # 80000c86 <release>
}
    8000239e:	60e2                	ld	ra,24(sp)
    800023a0:	6442                	ld	s0,16(sp)
    800023a2:	64a2                	ld	s1,8(sp)
    800023a4:	6105                	add	sp,sp,32
    800023a6:	8082                	ret

00000000800023a8 <killed>:

int killed(struct proc *p)
{
    800023a8:	1101                	add	sp,sp,-32
    800023aa:	ec06                	sd	ra,24(sp)
    800023ac:	e822                	sd	s0,16(sp)
    800023ae:	e426                	sd	s1,8(sp)
    800023b0:	e04a                	sd	s2,0(sp)
    800023b2:	1000                	add	s0,sp,32
    800023b4:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	81c080e7          	jalr	-2020(ra) # 80000bd2 <acquire>
  k = p->killed;
    800023be:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023c2:	8526                	mv	a0,s1
    800023c4:	fffff097          	auipc	ra,0xfffff
    800023c8:	8c2080e7          	jalr	-1854(ra) # 80000c86 <release>
  return k;
}
    800023cc:	854a                	mv	a0,s2
    800023ce:	60e2                	ld	ra,24(sp)
    800023d0:	6442                	ld	s0,16(sp)
    800023d2:	64a2                	ld	s1,8(sp)
    800023d4:	6902                	ld	s2,0(sp)
    800023d6:	6105                	add	sp,sp,32
    800023d8:	8082                	ret

00000000800023da <wait>:
{
    800023da:	715d                	add	sp,sp,-80
    800023dc:	e486                	sd	ra,72(sp)
    800023de:	e0a2                	sd	s0,64(sp)
    800023e0:	fc26                	sd	s1,56(sp)
    800023e2:	f84a                	sd	s2,48(sp)
    800023e4:	f44e                	sd	s3,40(sp)
    800023e6:	f052                	sd	s4,32(sp)
    800023e8:	ec56                	sd	s5,24(sp)
    800023ea:	e85a                	sd	s6,16(sp)
    800023ec:	e45e                	sd	s7,8(sp)
    800023ee:	e062                	sd	s8,0(sp)
    800023f0:	0880                	add	s0,sp,80
    800023f2:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023f4:	fffff097          	auipc	ra,0xfffff
    800023f8:	5b2080e7          	jalr	1458(ra) # 800019a6 <myproc>
    800023fc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023fe:	0000e517          	auipc	a0,0xe
    80002402:	79a50513          	add	a0,a0,1946 # 80010b98 <wait_lock>
    80002406:	ffffe097          	auipc	ra,0xffffe
    8000240a:	7cc080e7          	jalr	1996(ra) # 80000bd2 <acquire>
    havekids = 0;
    8000240e:	4b81                	li	s7,0
        if (pp->state == ZOMBIE)
    80002410:	4a15                	li	s4,5
        havekids = 1;
    80002412:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002414:	00015997          	auipc	s3,0x15
    80002418:	19c98993          	add	s3,s3,412 # 800175b0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000241c:	0000ec17          	auipc	s8,0xe
    80002420:	77cc0c13          	add	s8,s8,1916 # 80010b98 <wait_lock>
    80002424:	a0d1                	j	800024e8 <wait+0x10e>
          pid = pp->pid;
    80002426:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000242a:	000b0e63          	beqz	s6,80002446 <wait+0x6c>
    8000242e:	4691                	li	a3,4
    80002430:	02c48613          	add	a2,s1,44
    80002434:	85da                	mv	a1,s6
    80002436:	05093503          	ld	a0,80(s2)
    8000243a:	fffff097          	auipc	ra,0xfffff
    8000243e:	22c080e7          	jalr	556(ra) # 80001666 <copyout>
    80002442:	04054163          	bltz	a0,80002484 <wait+0xaa>
          freeproc(pp);
    80002446:	8526                	mv	a0,s1
    80002448:	fffff097          	auipc	ra,0xfffff
    8000244c:	710080e7          	jalr	1808(ra) # 80001b58 <freeproc>
          release(&pp->lock);
    80002450:	8526                	mv	a0,s1
    80002452:	fffff097          	auipc	ra,0xfffff
    80002456:	834080e7          	jalr	-1996(ra) # 80000c86 <release>
          release(&wait_lock);
    8000245a:	0000e517          	auipc	a0,0xe
    8000245e:	73e50513          	add	a0,a0,1854 # 80010b98 <wait_lock>
    80002462:	fffff097          	auipc	ra,0xfffff
    80002466:	824080e7          	jalr	-2012(ra) # 80000c86 <release>
}
    8000246a:	854e                	mv	a0,s3
    8000246c:	60a6                	ld	ra,72(sp)
    8000246e:	6406                	ld	s0,64(sp)
    80002470:	74e2                	ld	s1,56(sp)
    80002472:	7942                	ld	s2,48(sp)
    80002474:	79a2                	ld	s3,40(sp)
    80002476:	7a02                	ld	s4,32(sp)
    80002478:	6ae2                	ld	s5,24(sp)
    8000247a:	6b42                	ld	s6,16(sp)
    8000247c:	6ba2                	ld	s7,8(sp)
    8000247e:	6c02                	ld	s8,0(sp)
    80002480:	6161                	add	sp,sp,80
    80002482:	8082                	ret
            release(&pp->lock);
    80002484:	8526                	mv	a0,s1
    80002486:	fffff097          	auipc	ra,0xfffff
    8000248a:	800080e7          	jalr	-2048(ra) # 80000c86 <release>
            release(&wait_lock);
    8000248e:	0000e517          	auipc	a0,0xe
    80002492:	70a50513          	add	a0,a0,1802 # 80010b98 <wait_lock>
    80002496:	ffffe097          	auipc	ra,0xffffe
    8000249a:	7f0080e7          	jalr	2032(ra) # 80000c86 <release>
            return -1;
    8000249e:	59fd                	li	s3,-1
    800024a0:	b7e9                	j	8000246a <wait+0x90>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024a2:	19848493          	add	s1,s1,408
    800024a6:	03348463          	beq	s1,s3,800024ce <wait+0xf4>
      if (pp->parent == p)
    800024aa:	7c9c                	ld	a5,56(s1)
    800024ac:	ff279be3          	bne	a5,s2,800024a2 <wait+0xc8>
        acquire(&pp->lock);
    800024b0:	8526                	mv	a0,s1
    800024b2:	ffffe097          	auipc	ra,0xffffe
    800024b6:	720080e7          	jalr	1824(ra) # 80000bd2 <acquire>
        if (pp->state == ZOMBIE)
    800024ba:	4c9c                	lw	a5,24(s1)
    800024bc:	f74785e3          	beq	a5,s4,80002426 <wait+0x4c>
        release(&pp->lock);
    800024c0:	8526                	mv	a0,s1
    800024c2:	ffffe097          	auipc	ra,0xffffe
    800024c6:	7c4080e7          	jalr	1988(ra) # 80000c86 <release>
        havekids = 1;
    800024ca:	8756                	mv	a4,s5
    800024cc:	bfd9                	j	800024a2 <wait+0xc8>
    if (!havekids || killed(p))
    800024ce:	c31d                	beqz	a4,800024f4 <wait+0x11a>
    800024d0:	854a                	mv	a0,s2
    800024d2:	00000097          	auipc	ra,0x0
    800024d6:	ed6080e7          	jalr	-298(ra) # 800023a8 <killed>
    800024da:	ed09                	bnez	a0,800024f4 <wait+0x11a>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800024dc:	85e2                	mv	a1,s8
    800024de:	854a                	mv	a0,s2
    800024e0:	00000097          	auipc	ra,0x0
    800024e4:	c14080e7          	jalr	-1004(ra) # 800020f4 <sleep>
    havekids = 0;
    800024e8:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024ea:	0000f497          	auipc	s1,0xf
    800024ee:	ac648493          	add	s1,s1,-1338 # 80010fb0 <proc>
    800024f2:	bf65                	j	800024aa <wait+0xd0>
      release(&wait_lock);
    800024f4:	0000e517          	auipc	a0,0xe
    800024f8:	6a450513          	add	a0,a0,1700 # 80010b98 <wait_lock>
    800024fc:	ffffe097          	auipc	ra,0xffffe
    80002500:	78a080e7          	jalr	1930(ra) # 80000c86 <release>
      return -1;
    80002504:	59fd                	li	s3,-1
    80002506:	b795                	j	8000246a <wait+0x90>

0000000080002508 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002508:	7179                	add	sp,sp,-48
    8000250a:	f406                	sd	ra,40(sp)
    8000250c:	f022                	sd	s0,32(sp)
    8000250e:	ec26                	sd	s1,24(sp)
    80002510:	e84a                	sd	s2,16(sp)
    80002512:	e44e                	sd	s3,8(sp)
    80002514:	e052                	sd	s4,0(sp)
    80002516:	1800                	add	s0,sp,48
    80002518:	84aa                	mv	s1,a0
    8000251a:	892e                	mv	s2,a1
    8000251c:	89b2                	mv	s3,a2
    8000251e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002520:	fffff097          	auipc	ra,0xfffff
    80002524:	486080e7          	jalr	1158(ra) # 800019a6 <myproc>
  if (user_dst)
    80002528:	c08d                	beqz	s1,8000254a <either_copyout+0x42>
  {
    return copyout(p->pagetable, dst, src, len);
    8000252a:	86d2                	mv	a3,s4
    8000252c:	864e                	mv	a2,s3
    8000252e:	85ca                	mv	a1,s2
    80002530:	6928                	ld	a0,80(a0)
    80002532:	fffff097          	auipc	ra,0xfffff
    80002536:	134080e7          	jalr	308(ra) # 80001666 <copyout>
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000253a:	70a2                	ld	ra,40(sp)
    8000253c:	7402                	ld	s0,32(sp)
    8000253e:	64e2                	ld	s1,24(sp)
    80002540:	6942                	ld	s2,16(sp)
    80002542:	69a2                	ld	s3,8(sp)
    80002544:	6a02                	ld	s4,0(sp)
    80002546:	6145                	add	sp,sp,48
    80002548:	8082                	ret
    memmove((char *)dst, src, len);
    8000254a:	000a061b          	sext.w	a2,s4
    8000254e:	85ce                	mv	a1,s3
    80002550:	854a                	mv	a0,s2
    80002552:	ffffe097          	auipc	ra,0xffffe
    80002556:	7d8080e7          	jalr	2008(ra) # 80000d2a <memmove>
    return 0;
    8000255a:	8526                	mv	a0,s1
    8000255c:	bff9                	j	8000253a <either_copyout+0x32>

000000008000255e <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000255e:	7179                	add	sp,sp,-48
    80002560:	f406                	sd	ra,40(sp)
    80002562:	f022                	sd	s0,32(sp)
    80002564:	ec26                	sd	s1,24(sp)
    80002566:	e84a                	sd	s2,16(sp)
    80002568:	e44e                	sd	s3,8(sp)
    8000256a:	e052                	sd	s4,0(sp)
    8000256c:	1800                	add	s0,sp,48
    8000256e:	892a                	mv	s2,a0
    80002570:	84ae                	mv	s1,a1
    80002572:	89b2                	mv	s3,a2
    80002574:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002576:	fffff097          	auipc	ra,0xfffff
    8000257a:	430080e7          	jalr	1072(ra) # 800019a6 <myproc>
  if (user_src)
    8000257e:	c08d                	beqz	s1,800025a0 <either_copyin+0x42>
  {
    return copyin(p->pagetable, dst, src, len);
    80002580:	86d2                	mv	a3,s4
    80002582:	864e                	mv	a2,s3
    80002584:	85ca                	mv	a1,s2
    80002586:	6928                	ld	a0,80(a0)
    80002588:	fffff097          	auipc	ra,0xfffff
    8000258c:	16a080e7          	jalr	362(ra) # 800016f2 <copyin>
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002590:	70a2                	ld	ra,40(sp)
    80002592:	7402                	ld	s0,32(sp)
    80002594:	64e2                	ld	s1,24(sp)
    80002596:	6942                	ld	s2,16(sp)
    80002598:	69a2                	ld	s3,8(sp)
    8000259a:	6a02                	ld	s4,0(sp)
    8000259c:	6145                	add	sp,sp,48
    8000259e:	8082                	ret
    memmove(dst, (char *)src, len);
    800025a0:	000a061b          	sext.w	a2,s4
    800025a4:	85ce                	mv	a1,s3
    800025a6:	854a                	mv	a0,s2
    800025a8:	ffffe097          	auipc	ra,0xffffe
    800025ac:	782080e7          	jalr	1922(ra) # 80000d2a <memmove>
    return 0;
    800025b0:	8526                	mv	a0,s1
    800025b2:	bff9                	j	80002590 <either_copyin+0x32>

00000000800025b4 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800025b4:	715d                	add	sp,sp,-80
    800025b6:	e486                	sd	ra,72(sp)
    800025b8:	e0a2                	sd	s0,64(sp)
    800025ba:	fc26                	sd	s1,56(sp)
    800025bc:	f84a                	sd	s2,48(sp)
    800025be:	f44e                	sd	s3,40(sp)
    800025c0:	f052                	sd	s4,32(sp)
    800025c2:	ec56                	sd	s5,24(sp)
    800025c4:	e85a                	sd	s6,16(sp)
    800025c6:	e45e                	sd	s7,8(sp)
    800025c8:	0880                	add	s0,sp,80
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    800025ca:	00006517          	auipc	a0,0x6
    800025ce:	afe50513          	add	a0,a0,-1282 # 800080c8 <digits+0x88>
    800025d2:	ffffe097          	auipc	ra,0xffffe
    800025d6:	fb4080e7          	jalr	-76(ra) # 80000586 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    800025da:	0000f497          	auipc	s1,0xf
    800025de:	b2e48493          	add	s1,s1,-1234 # 80011108 <proc+0x158>
    800025e2:	00015917          	auipc	s2,0x15
    800025e6:	12690913          	add	s2,s2,294 # 80017708 <bcache+0x140>
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ea:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025ec:	00006997          	auipc	s3,0x6
    800025f0:	c9498993          	add	s3,s3,-876 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800025f4:	00006a97          	auipc	s5,0x6
    800025f8:	c94a8a93          	add	s5,s5,-876 # 80008288 <digits+0x248>
    printf("\n");
    800025fc:	00006a17          	auipc	s4,0x6
    80002600:	acca0a13          	add	s4,s4,-1332 # 800080c8 <digits+0x88>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002604:	00006b97          	auipc	s7,0x6
    80002608:	cc4b8b93          	add	s7,s7,-828 # 800082c8 <states.0>
    8000260c:	a00d                	j	8000262e <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000260e:	ed86a583          	lw	a1,-296(a3)
    80002612:	8556                	mv	a0,s5
    80002614:	ffffe097          	auipc	ra,0xffffe
    80002618:	f72080e7          	jalr	-142(ra) # 80000586 <printf>
    printf("\n");
    8000261c:	8552                	mv	a0,s4
    8000261e:	ffffe097          	auipc	ra,0xffffe
    80002622:	f68080e7          	jalr	-152(ra) # 80000586 <printf>
  for (p = proc; p < &proc[NPROC]; p++)
    80002626:	19848493          	add	s1,s1,408
    8000262a:	03248263          	beq	s1,s2,8000264e <procdump+0x9a>
    if (p->state == UNUSED)
    8000262e:	86a6                	mv	a3,s1
    80002630:	ec04a783          	lw	a5,-320(s1)
    80002634:	dbed                	beqz	a5,80002626 <procdump+0x72>
      state = "???";
    80002636:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002638:	fcfb6be3          	bltu	s6,a5,8000260e <procdump+0x5a>
    8000263c:	02079713          	sll	a4,a5,0x20
    80002640:	01d75793          	srl	a5,a4,0x1d
    80002644:	97de                	add	a5,a5,s7
    80002646:	6390                	ld	a2,0(a5)
    80002648:	f279                	bnez	a2,8000260e <procdump+0x5a>
      state = "???";
    8000264a:	864e                	mv	a2,s3
    8000264c:	b7c9                	j	8000260e <procdump+0x5a>
  }
}
    8000264e:	60a6                	ld	ra,72(sp)
    80002650:	6406                	ld	s0,64(sp)
    80002652:	74e2                	ld	s1,56(sp)
    80002654:	7942                	ld	s2,48(sp)
    80002656:	79a2                	ld	s3,40(sp)
    80002658:	7a02                	ld	s4,32(sp)
    8000265a:	6ae2                	ld	s5,24(sp)
    8000265c:	6b42                	ld	s6,16(sp)
    8000265e:	6ba2                	ld	s7,8(sp)
    80002660:	6161                	add	sp,sp,80
    80002662:	8082                	ret

0000000080002664 <waitx>:

// waitx
int waitx(uint64 addr, uint *wtime, uint *rtime)
{
    80002664:	711d                	add	sp,sp,-96
    80002666:	ec86                	sd	ra,88(sp)
    80002668:	e8a2                	sd	s0,80(sp)
    8000266a:	e4a6                	sd	s1,72(sp)
    8000266c:	e0ca                	sd	s2,64(sp)
    8000266e:	fc4e                	sd	s3,56(sp)
    80002670:	f852                	sd	s4,48(sp)
    80002672:	f456                	sd	s5,40(sp)
    80002674:	f05a                	sd	s6,32(sp)
    80002676:	ec5e                	sd	s7,24(sp)
    80002678:	e862                	sd	s8,16(sp)
    8000267a:	e466                	sd	s9,8(sp)
    8000267c:	e06a                	sd	s10,0(sp)
    8000267e:	1080                	add	s0,sp,96
    80002680:	8b2a                	mv	s6,a0
    80002682:	8bae                	mv	s7,a1
    80002684:	8c32                	mv	s8,a2
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
    80002686:	fffff097          	auipc	ra,0xfffff
    8000268a:	320080e7          	jalr	800(ra) # 800019a6 <myproc>
    8000268e:	892a                	mv	s2,a0

  acquire(&wait_lock);
    80002690:	0000e517          	auipc	a0,0xe
    80002694:	50850513          	add	a0,a0,1288 # 80010b98 <wait_lock>
    80002698:	ffffe097          	auipc	ra,0xffffe
    8000269c:	53a080e7          	jalr	1338(ra) # 80000bd2 <acquire>

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    800026a0:	4c81                	li	s9,0
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
    800026a2:	4a15                	li	s4,5
        havekids = 1;
    800026a4:	4a85                	li	s5,1
    for (np = proc; np < &proc[NPROC]; np++)
    800026a6:	00015997          	auipc	s3,0x15
    800026aa:	f0a98993          	add	s3,s3,-246 # 800175b0 <tickslock>
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); // DOC: wait-sleep
    800026ae:	0000ed17          	auipc	s10,0xe
    800026b2:	4ead0d13          	add	s10,s10,1258 # 80010b98 <wait_lock>
    800026b6:	a8e9                	j	80002790 <waitx+0x12c>
          pid = np->pid;
    800026b8:	0304a983          	lw	s3,48(s1)
          *rtime = np->rtime;
    800026bc:	1684a783          	lw	a5,360(s1)
    800026c0:	00fc2023          	sw	a5,0(s8)
          *wtime = np->etime - np->ctime - np->rtime;
    800026c4:	16c4a703          	lw	a4,364(s1)
    800026c8:	9f3d                	addw	a4,a4,a5
    800026ca:	1704a783          	lw	a5,368(s1)
    800026ce:	9f99                	subw	a5,a5,a4
    800026d0:	00fba023          	sw	a5,0(s7)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800026d4:	000b0e63          	beqz	s6,800026f0 <waitx+0x8c>
    800026d8:	4691                	li	a3,4
    800026da:	02c48613          	add	a2,s1,44
    800026de:	85da                	mv	a1,s6
    800026e0:	05093503          	ld	a0,80(s2)
    800026e4:	fffff097          	auipc	ra,0xfffff
    800026e8:	f82080e7          	jalr	-126(ra) # 80001666 <copyout>
    800026ec:	04054363          	bltz	a0,80002732 <waitx+0xce>
          freeproc(np);
    800026f0:	8526                	mv	a0,s1
    800026f2:	fffff097          	auipc	ra,0xfffff
    800026f6:	466080e7          	jalr	1126(ra) # 80001b58 <freeproc>
          release(&np->lock);
    800026fa:	8526                	mv	a0,s1
    800026fc:	ffffe097          	auipc	ra,0xffffe
    80002700:	58a080e7          	jalr	1418(ra) # 80000c86 <release>
          release(&wait_lock);
    80002704:	0000e517          	auipc	a0,0xe
    80002708:	49450513          	add	a0,a0,1172 # 80010b98 <wait_lock>
    8000270c:	ffffe097          	auipc	ra,0xffffe
    80002710:	57a080e7          	jalr	1402(ra) # 80000c86 <release>
  }
}
    80002714:	854e                	mv	a0,s3
    80002716:	60e6                	ld	ra,88(sp)
    80002718:	6446                	ld	s0,80(sp)
    8000271a:	64a6                	ld	s1,72(sp)
    8000271c:	6906                	ld	s2,64(sp)
    8000271e:	79e2                	ld	s3,56(sp)
    80002720:	7a42                	ld	s4,48(sp)
    80002722:	7aa2                	ld	s5,40(sp)
    80002724:	7b02                	ld	s6,32(sp)
    80002726:	6be2                	ld	s7,24(sp)
    80002728:	6c42                	ld	s8,16(sp)
    8000272a:	6ca2                	ld	s9,8(sp)
    8000272c:	6d02                	ld	s10,0(sp)
    8000272e:	6125                	add	sp,sp,96
    80002730:	8082                	ret
            release(&np->lock);
    80002732:	8526                	mv	a0,s1
    80002734:	ffffe097          	auipc	ra,0xffffe
    80002738:	552080e7          	jalr	1362(ra) # 80000c86 <release>
            release(&wait_lock);
    8000273c:	0000e517          	auipc	a0,0xe
    80002740:	45c50513          	add	a0,a0,1116 # 80010b98 <wait_lock>
    80002744:	ffffe097          	auipc	ra,0xffffe
    80002748:	542080e7          	jalr	1346(ra) # 80000c86 <release>
            return -1;
    8000274c:	59fd                	li	s3,-1
    8000274e:	b7d9                	j	80002714 <waitx+0xb0>
    for (np = proc; np < &proc[NPROC]; np++)
    80002750:	19848493          	add	s1,s1,408
    80002754:	03348463          	beq	s1,s3,8000277c <waitx+0x118>
      if (np->parent == p)
    80002758:	7c9c                	ld	a5,56(s1)
    8000275a:	ff279be3          	bne	a5,s2,80002750 <waitx+0xec>
        acquire(&np->lock);
    8000275e:	8526                	mv	a0,s1
    80002760:	ffffe097          	auipc	ra,0xffffe
    80002764:	472080e7          	jalr	1138(ra) # 80000bd2 <acquire>
        if (np->state == ZOMBIE)
    80002768:	4c9c                	lw	a5,24(s1)
    8000276a:	f54787e3          	beq	a5,s4,800026b8 <waitx+0x54>
        release(&np->lock);
    8000276e:	8526                	mv	a0,s1
    80002770:	ffffe097          	auipc	ra,0xffffe
    80002774:	516080e7          	jalr	1302(ra) # 80000c86 <release>
        havekids = 1;
    80002778:	8756                	mv	a4,s5
    8000277a:	bfd9                	j	80002750 <waitx+0xec>
    if (!havekids || p->killed)
    8000277c:	c305                	beqz	a4,8000279c <waitx+0x138>
    8000277e:	02892783          	lw	a5,40(s2)
    80002782:	ef89                	bnez	a5,8000279c <waitx+0x138>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002784:	85ea                	mv	a1,s10
    80002786:	854a                	mv	a0,s2
    80002788:	00000097          	auipc	ra,0x0
    8000278c:	96c080e7          	jalr	-1684(ra) # 800020f4 <sleep>
    havekids = 0;
    80002790:	8766                	mv	a4,s9
    for (np = proc; np < &proc[NPROC]; np++)
    80002792:	0000f497          	auipc	s1,0xf
    80002796:	81e48493          	add	s1,s1,-2018 # 80010fb0 <proc>
    8000279a:	bf7d                	j	80002758 <waitx+0xf4>
      release(&wait_lock);
    8000279c:	0000e517          	auipc	a0,0xe
    800027a0:	3fc50513          	add	a0,a0,1020 # 80010b98 <wait_lock>
    800027a4:	ffffe097          	auipc	ra,0xffffe
    800027a8:	4e2080e7          	jalr	1250(ra) # 80000c86 <release>
      return -1;
    800027ac:	59fd                	li	s3,-1
    800027ae:	b79d                	j	80002714 <waitx+0xb0>

00000000800027b0 <update_time>:

void update_time()
{
    800027b0:	7179                	add	sp,sp,-48
    800027b2:	f406                	sd	ra,40(sp)
    800027b4:	f022                	sd	s0,32(sp)
    800027b6:	ec26                	sd	s1,24(sp)
    800027b8:	e84a                	sd	s2,16(sp)
    800027ba:	e44e                	sd	s3,8(sp)
    800027bc:	1800                	add	s0,sp,48
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; p++)
    800027be:	0000e497          	auipc	s1,0xe
    800027c2:	7f248493          	add	s1,s1,2034 # 80010fb0 <proc>
  {
    acquire(&p->lock);
    if (p->state == RUNNING)
    800027c6:	4991                	li	s3,4
  for (p = proc; p < &proc[NPROC]; p++)
    800027c8:	00015917          	auipc	s2,0x15
    800027cc:	de890913          	add	s2,s2,-536 # 800175b0 <tickslock>
    800027d0:	a811                	j	800027e4 <update_time+0x34>
    {
      p->rtime++;
    }
    release(&p->lock);
    800027d2:	8526                	mv	a0,s1
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	4b2080e7          	jalr	1202(ra) # 80000c86 <release>
  for (p = proc; p < &proc[NPROC]; p++)
    800027dc:	19848493          	add	s1,s1,408
    800027e0:	03248063          	beq	s1,s2,80002800 <update_time+0x50>
    acquire(&p->lock);
    800027e4:	8526                	mv	a0,s1
    800027e6:	ffffe097          	auipc	ra,0xffffe
    800027ea:	3ec080e7          	jalr	1004(ra) # 80000bd2 <acquire>
    if (p->state == RUNNING)
    800027ee:	4c9c                	lw	a5,24(s1)
    800027f0:	ff3791e3          	bne	a5,s3,800027d2 <update_time+0x22>
      p->rtime++;
    800027f4:	1684a783          	lw	a5,360(s1)
    800027f8:	2785                	addw	a5,a5,1
    800027fa:	16f4a423          	sw	a5,360(s1)
    800027fe:	bfd1                	j	800027d2 <update_time+0x22>
  }
    80002800:	70a2                	ld	ra,40(sp)
    80002802:	7402                	ld	s0,32(sp)
    80002804:	64e2                	ld	s1,24(sp)
    80002806:	6942                	ld	s2,16(sp)
    80002808:	69a2                	ld	s3,8(sp)
    8000280a:	6145                	add	sp,sp,48
    8000280c:	8082                	ret

000000008000280e <swtch>:
    8000280e:	00153023          	sd	ra,0(a0)
    80002812:	00253423          	sd	sp,8(a0)
    80002816:	e900                	sd	s0,16(a0)
    80002818:	ed04                	sd	s1,24(a0)
    8000281a:	03253023          	sd	s2,32(a0)
    8000281e:	03353423          	sd	s3,40(a0)
    80002822:	03453823          	sd	s4,48(a0)
    80002826:	03553c23          	sd	s5,56(a0)
    8000282a:	05653023          	sd	s6,64(a0)
    8000282e:	05753423          	sd	s7,72(a0)
    80002832:	05853823          	sd	s8,80(a0)
    80002836:	05953c23          	sd	s9,88(a0)
    8000283a:	07a53023          	sd	s10,96(a0)
    8000283e:	07b53423          	sd	s11,104(a0)
    80002842:	0005b083          	ld	ra,0(a1)
    80002846:	0085b103          	ld	sp,8(a1)
    8000284a:	6980                	ld	s0,16(a1)
    8000284c:	6d84                	ld	s1,24(a1)
    8000284e:	0205b903          	ld	s2,32(a1)
    80002852:	0285b983          	ld	s3,40(a1)
    80002856:	0305ba03          	ld	s4,48(a1)
    8000285a:	0385ba83          	ld	s5,56(a1)
    8000285e:	0405bb03          	ld	s6,64(a1)
    80002862:	0485bb83          	ld	s7,72(a1)
    80002866:	0505bc03          	ld	s8,80(a1)
    8000286a:	0585bc83          	ld	s9,88(a1)
    8000286e:	0605bd03          	ld	s10,96(a1)
    80002872:	0685bd83          	ld	s11,104(a1)
    80002876:	8082                	ret

0000000080002878 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002878:	1141                	add	sp,sp,-16
    8000287a:	e406                	sd	ra,8(sp)
    8000287c:	e022                	sd	s0,0(sp)
    8000287e:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    80002880:	00006597          	auipc	a1,0x6
    80002884:	a7858593          	add	a1,a1,-1416 # 800082f8 <states.0+0x30>
    80002888:	00015517          	auipc	a0,0x15
    8000288c:	d2850513          	add	a0,a0,-728 # 800175b0 <tickslock>
    80002890:	ffffe097          	auipc	ra,0xffffe
    80002894:	2b2080e7          	jalr	690(ra) # 80000b42 <initlock>
}
    80002898:	60a2                	ld	ra,8(sp)
    8000289a:	6402                	ld	s0,0(sp)
    8000289c:	0141                	add	sp,sp,16
    8000289e:	8082                	ret

00000000800028a0 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    800028a0:	1141                	add	sp,sp,-16
    800028a2:	e422                	sd	s0,8(sp)
    800028a4:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028a6:	00003797          	auipc	a5,0x3
    800028aa:	67a78793          	add	a5,a5,1658 # 80005f20 <kernelvec>
    800028ae:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028b2:	6422                	ld	s0,8(sp)
    800028b4:	0141                	add	sp,sp,16
    800028b6:	8082                	ret

00000000800028b8 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    800028b8:	1141                	add	sp,sp,-16
    800028ba:	e406                	sd	ra,8(sp)
    800028bc:	e022                	sd	s0,0(sp)
    800028be:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    800028c0:	fffff097          	auipc	ra,0xfffff
    800028c4:	0e6080e7          	jalr	230(ra) # 800019a6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028c8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028cc:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028ce:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800028d2:	00004697          	auipc	a3,0x4
    800028d6:	72e68693          	add	a3,a3,1838 # 80007000 <_trampoline>
    800028da:	00004717          	auipc	a4,0x4
    800028de:	72670713          	add	a4,a4,1830 # 80007000 <_trampoline>
    800028e2:	8f15                	sub	a4,a4,a3
    800028e4:	040007b7          	lui	a5,0x4000
    800028e8:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800028ea:	07b2                	sll	a5,a5,0xc
    800028ec:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028ee:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800028f2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800028f4:	18002673          	csrr	a2,satp
    800028f8:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800028fa:	6d30                	ld	a2,88(a0)
    800028fc:	6138                	ld	a4,64(a0)
    800028fe:	6585                	lui	a1,0x1
    80002900:	972e                	add	a4,a4,a1
    80002902:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002904:	6d38                	ld	a4,88(a0)
    80002906:	00000617          	auipc	a2,0x0
    8000290a:	14260613          	add	a2,a2,322 # 80002a48 <usertrap>
    8000290e:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002910:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002912:	8612                	mv	a2,tp
    80002914:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002916:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000291a:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000291e:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002922:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002926:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002928:	6f18                	ld	a4,24(a4)
    8000292a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000292e:	6928                	ld	a0,80(a0)
    80002930:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002932:	00004717          	auipc	a4,0x4
    80002936:	76a70713          	add	a4,a4,1898 # 8000709c <userret>
    8000293a:	8f15                	sub	a4,a4,a3
    8000293c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000293e:	577d                	li	a4,-1
    80002940:	177e                	sll	a4,a4,0x3f
    80002942:	8d59                	or	a0,a0,a4
    80002944:	9782                	jalr	a5
}
    80002946:	60a2                	ld	ra,8(sp)
    80002948:	6402                	ld	s0,0(sp)
    8000294a:	0141                	add	sp,sp,16
    8000294c:	8082                	ret

000000008000294e <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    8000294e:	1101                	add	sp,sp,-32
    80002950:	ec06                	sd	ra,24(sp)
    80002952:	e822                	sd	s0,16(sp)
    80002954:	e426                	sd	s1,8(sp)
    80002956:	e04a                	sd	s2,0(sp)
    80002958:	1000                	add	s0,sp,32
  acquire(&tickslock);
    8000295a:	00015917          	auipc	s2,0x15
    8000295e:	c5690913          	add	s2,s2,-938 # 800175b0 <tickslock>
    80002962:	854a                	mv	a0,s2
    80002964:	ffffe097          	auipc	ra,0xffffe
    80002968:	26e080e7          	jalr	622(ra) # 80000bd2 <acquire>
  ticks++;
    8000296c:	00006497          	auipc	s1,0x6
    80002970:	fa448493          	add	s1,s1,-92 # 80008910 <ticks>
    80002974:	409c                	lw	a5,0(s1)
    80002976:	2785                	addw	a5,a5,1
    80002978:	c09c                	sw	a5,0(s1)
  update_time();
    8000297a:	00000097          	auipc	ra,0x0
    8000297e:	e36080e7          	jalr	-458(ra) # 800027b0 <update_time>
  //   // {
  //   //   p->wtime++;
  //   // }
  //   release(&p->lock);
  // }
  wakeup(&ticks);
    80002982:	8526                	mv	a0,s1
    80002984:	fffff097          	auipc	ra,0xfffff
    80002988:	7d4080e7          	jalr	2004(ra) # 80002158 <wakeup>
  release(&tickslock);
    8000298c:	854a                	mv	a0,s2
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	2f8080e7          	jalr	760(ra) # 80000c86 <release>
}
    80002996:	60e2                	ld	ra,24(sp)
    80002998:	6442                	ld	s0,16(sp)
    8000299a:	64a2                	ld	s1,8(sp)
    8000299c:	6902                	ld	s2,0(sp)
    8000299e:	6105                	add	sp,sp,32
    800029a0:	8082                	ret

00000000800029a2 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029a2:	142027f3          	csrr	a5,scause

    return 2;
  }
  else
  {
    return 0;
    800029a6:	4501                	li	a0,0
  if ((scause & 0x8000000000000000L) &&
    800029a8:	0807df63          	bgez	a5,80002a46 <devintr+0xa4>
{
    800029ac:	1101                	add	sp,sp,-32
    800029ae:	ec06                	sd	ra,24(sp)
    800029b0:	e822                	sd	s0,16(sp)
    800029b2:	e426                	sd	s1,8(sp)
    800029b4:	1000                	add	s0,sp,32
      (scause & 0xff) == 9)
    800029b6:	0ff7f713          	zext.b	a4,a5
  if ((scause & 0x8000000000000000L) &&
    800029ba:	46a5                	li	a3,9
    800029bc:	00d70d63          	beq	a4,a3,800029d6 <devintr+0x34>
  else if (scause == 0x8000000000000001L)
    800029c0:	577d                	li	a4,-1
    800029c2:	177e                	sll	a4,a4,0x3f
    800029c4:	0705                	add	a4,a4,1
    return 0;
    800029c6:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    800029c8:	04e78e63          	beq	a5,a4,80002a24 <devintr+0x82>
  }
}
    800029cc:	60e2                	ld	ra,24(sp)
    800029ce:	6442                	ld	s0,16(sp)
    800029d0:	64a2                	ld	s1,8(sp)
    800029d2:	6105                	add	sp,sp,32
    800029d4:	8082                	ret
    int irq = plic_claim();
    800029d6:	00003097          	auipc	ra,0x3
    800029da:	652080e7          	jalr	1618(ra) # 80006028 <plic_claim>
    800029de:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    800029e0:	47a9                	li	a5,10
    800029e2:	02f50763          	beq	a0,a5,80002a10 <devintr+0x6e>
    else if (irq == VIRTIO0_IRQ)
    800029e6:	4785                	li	a5,1
    800029e8:	02f50963          	beq	a0,a5,80002a1a <devintr+0x78>
    return 1;
    800029ec:	4505                	li	a0,1
    else if (irq)
    800029ee:	dcf9                	beqz	s1,800029cc <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    800029f0:	85a6                	mv	a1,s1
    800029f2:	00006517          	auipc	a0,0x6
    800029f6:	90e50513          	add	a0,a0,-1778 # 80008300 <states.0+0x38>
    800029fa:	ffffe097          	auipc	ra,0xffffe
    800029fe:	b8c080e7          	jalr	-1140(ra) # 80000586 <printf>
      plic_complete(irq);
    80002a02:	8526                	mv	a0,s1
    80002a04:	00003097          	auipc	ra,0x3
    80002a08:	648080e7          	jalr	1608(ra) # 8000604c <plic_complete>
    return 1;
    80002a0c:	4505                	li	a0,1
    80002a0e:	bf7d                	j	800029cc <devintr+0x2a>
      uartintr();
    80002a10:	ffffe097          	auipc	ra,0xffffe
    80002a14:	f84080e7          	jalr	-124(ra) # 80000994 <uartintr>
    if (irq)
    80002a18:	b7ed                	j	80002a02 <devintr+0x60>
      virtio_disk_intr();
    80002a1a:	00004097          	auipc	ra,0x4
    80002a1e:	af8080e7          	jalr	-1288(ra) # 80006512 <virtio_disk_intr>
    if (irq)
    80002a22:	b7c5                	j	80002a02 <devintr+0x60>
    if (cpuid() == 0)
    80002a24:	fffff097          	auipc	ra,0xfffff
    80002a28:	f56080e7          	jalr	-170(ra) # 8000197a <cpuid>
    80002a2c:	c901                	beqz	a0,80002a3c <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a2e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a32:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a34:	14479073          	csrw	sip,a5
    return 2;
    80002a38:	4509                	li	a0,2
    80002a3a:	bf49                	j	800029cc <devintr+0x2a>
      clockintr();
    80002a3c:	00000097          	auipc	ra,0x0
    80002a40:	f12080e7          	jalr	-238(ra) # 8000294e <clockintr>
    80002a44:	b7ed                	j	80002a2e <devintr+0x8c>
}
    80002a46:	8082                	ret

0000000080002a48 <usertrap>:
{
    80002a48:	1101                	add	sp,sp,-32
    80002a4a:	ec06                	sd	ra,24(sp)
    80002a4c:	e822                	sd	s0,16(sp)
    80002a4e:	e426                	sd	s1,8(sp)
    80002a50:	e04a                	sd	s2,0(sp)
    80002a52:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a54:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002a58:	1007f793          	and	a5,a5,256
    80002a5c:	e3b1                	bnez	a5,80002aa0 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a5e:	00003797          	auipc	a5,0x3
    80002a62:	4c278793          	add	a5,a5,1218 # 80005f20 <kernelvec>
    80002a66:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a6a:	fffff097          	auipc	ra,0xfffff
    80002a6e:	f3c080e7          	jalr	-196(ra) # 800019a6 <myproc>
    80002a72:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a74:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a76:	14102773          	csrr	a4,sepc
    80002a7a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a7c:	14202773          	csrr	a4,scause
  if (r_scause() == 8)
    80002a80:	47a1                	li	a5,8
    80002a82:	02f70763          	beq	a4,a5,80002ab0 <usertrap+0x68>
  else if ((which_dev = devintr()) != 0)
    80002a86:	00000097          	auipc	ra,0x0
    80002a8a:	f1c080e7          	jalr	-228(ra) # 800029a2 <devintr>
    80002a8e:	892a                	mv	s2,a0
    80002a90:	c92d                	beqz	a0,80002b02 <usertrap+0xba>
  if (killed(p))
    80002a92:	8526                	mv	a0,s1
    80002a94:	00000097          	auipc	ra,0x0
    80002a98:	914080e7          	jalr	-1772(ra) # 800023a8 <killed>
    80002a9c:	c555                	beqz	a0,80002b48 <usertrap+0x100>
    80002a9e:	a045                	j	80002b3e <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80002aa0:	00006517          	auipc	a0,0x6
    80002aa4:	88050513          	add	a0,a0,-1920 # 80008320 <states.0+0x58>
    80002aa8:	ffffe097          	auipc	ra,0xffffe
    80002aac:	a94080e7          	jalr	-1388(ra) # 8000053c <panic>
    if (killed(p))
    80002ab0:	00000097          	auipc	ra,0x0
    80002ab4:	8f8080e7          	jalr	-1800(ra) # 800023a8 <killed>
    80002ab8:	ed1d                	bnez	a0,80002af6 <usertrap+0xae>
    p->trapframe->epc += 4;
    80002aba:	6cb8                	ld	a4,88(s1)
    80002abc:	6f1c                	ld	a5,24(a4)
    80002abe:	0791                	add	a5,a5,4
    80002ac0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ac2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ac6:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002aca:	10079073          	csrw	sstatus,a5
    syscall();
    80002ace:	00000097          	auipc	ra,0x0
    80002ad2:	318080e7          	jalr	792(ra) # 80002de6 <syscall>
  if (killed(p))
    80002ad6:	8526                	mv	a0,s1
    80002ad8:	00000097          	auipc	ra,0x0
    80002adc:	8d0080e7          	jalr	-1840(ra) # 800023a8 <killed>
    80002ae0:	ed31                	bnez	a0,80002b3c <usertrap+0xf4>
  usertrapret();
    80002ae2:	00000097          	auipc	ra,0x0
    80002ae6:	dd6080e7          	jalr	-554(ra) # 800028b8 <usertrapret>
}
    80002aea:	60e2                	ld	ra,24(sp)
    80002aec:	6442                	ld	s0,16(sp)
    80002aee:	64a2                	ld	s1,8(sp)
    80002af0:	6902                	ld	s2,0(sp)
    80002af2:	6105                	add	sp,sp,32
    80002af4:	8082                	ret
      exit(-1);
    80002af6:	557d                	li	a0,-1
    80002af8:	fffff097          	auipc	ra,0xfffff
    80002afc:	730080e7          	jalr	1840(ra) # 80002228 <exit>
    80002b00:	bf6d                	j	80002aba <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b02:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b06:	5890                	lw	a2,48(s1)
    80002b08:	00006517          	auipc	a0,0x6
    80002b0c:	83850513          	add	a0,a0,-1992 # 80008340 <states.0+0x78>
    80002b10:	ffffe097          	auipc	ra,0xffffe
    80002b14:	a76080e7          	jalr	-1418(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b18:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b1c:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b20:	00006517          	auipc	a0,0x6
    80002b24:	85050513          	add	a0,a0,-1968 # 80008370 <states.0+0xa8>
    80002b28:	ffffe097          	auipc	ra,0xffffe
    80002b2c:	a5e080e7          	jalr	-1442(ra) # 80000586 <printf>
    setkilled(p);
    80002b30:	8526                	mv	a0,s1
    80002b32:	00000097          	auipc	ra,0x0
    80002b36:	84a080e7          	jalr	-1974(ra) # 8000237c <setkilled>
    80002b3a:	bf71                	j	80002ad6 <usertrap+0x8e>
  if (killed(p))
    80002b3c:	4901                	li	s2,0
    exit(-1);
    80002b3e:	557d                	li	a0,-1
    80002b40:	fffff097          	auipc	ra,0xfffff
    80002b44:	6e8080e7          	jalr	1768(ra) # 80002228 <exit>
  if(which_dev == 2) {
    80002b48:	4789                	li	a5,2
    80002b4a:	f8f91ce3          	bne	s2,a5,80002ae2 <usertrap+0x9a>
    if (p->interval) {
    80002b4e:	1804a703          	lw	a4,384(s1)
    80002b52:	db41                	beqz	a4,80002ae2 <usertrap+0x9a>
      p->now_ticks++;
    80002b54:	1844a783          	lw	a5,388(s1)
    80002b58:	2785                	addw	a5,a5,1
    80002b5a:	0007869b          	sext.w	a3,a5
    80002b5e:	18f4a223          	sw	a5,388(s1)
      if (!p->sigalarm_status && p->interval > 0 && p->now_ticks >= p->interval) {
    80002b62:	1904a783          	lw	a5,400(s1)
    80002b66:	ffb5                	bnez	a5,80002ae2 <usertrap+0x9a>
    80002b68:	f6e05de3          	blez	a4,80002ae2 <usertrap+0x9a>
    80002b6c:	f6e6cbe3          	blt	a3,a4,80002ae2 <usertrap+0x9a>
        p->now_ticks = 0;
    80002b70:	1804a223          	sw	zero,388(s1)
        p->sigalarm_status = 1;
    80002b74:	4785                	li	a5,1
    80002b76:	18f4a823          	sw	a5,400(s1)
        p->alarm_trapframe = kalloc();
    80002b7a:	ffffe097          	auipc	ra,0xffffe
    80002b7e:	f68080e7          	jalr	-152(ra) # 80000ae2 <kalloc>
    80002b82:	18a4b423          	sd	a0,392(s1)
        memmove(p->alarm_trapframe, p->trapframe, PGSIZE);
    80002b86:	6605                	lui	a2,0x1
    80002b88:	6cac                	ld	a1,88(s1)
    80002b8a:	ffffe097          	auipc	ra,0xffffe
    80002b8e:	1a0080e7          	jalr	416(ra) # 80000d2a <memmove>
        p->trapframe->epc = p->handler;
    80002b92:	6cbc                	ld	a5,88(s1)
    80002b94:	1784b703          	ld	a4,376(s1)
    80002b98:	ef98                	sd	a4,24(a5)
    80002b9a:	b7a1                	j	80002ae2 <usertrap+0x9a>

0000000080002b9c <kerneltrap>:
{
    80002b9c:	7179                	add	sp,sp,-48
    80002b9e:	f406                	sd	ra,40(sp)
    80002ba0:	f022                	sd	s0,32(sp)
    80002ba2:	ec26                	sd	s1,24(sp)
    80002ba4:	e84a                	sd	s2,16(sp)
    80002ba6:	e44e                	sd	s3,8(sp)
    80002ba8:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002baa:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bae:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bb2:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002bb6:	1004f793          	and	a5,s1,256
    80002bba:	cb85                	beqz	a5,80002bea <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bbc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002bc0:	8b89                	and	a5,a5,2
  if (intr_get() != 0)
    80002bc2:	ef85                	bnez	a5,80002bfa <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80002bc4:	00000097          	auipc	ra,0x0
    80002bc8:	dde080e7          	jalr	-546(ra) # 800029a2 <devintr>
    80002bcc:	cd1d                	beqz	a0,80002c0a <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002bce:	4789                	li	a5,2
    80002bd0:	06f50a63          	beq	a0,a5,80002c44 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bd4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bd8:	10049073          	csrw	sstatus,s1
}
    80002bdc:	70a2                	ld	ra,40(sp)
    80002bde:	7402                	ld	s0,32(sp)
    80002be0:	64e2                	ld	s1,24(sp)
    80002be2:	6942                	ld	s2,16(sp)
    80002be4:	69a2                	ld	s3,8(sp)
    80002be6:	6145                	add	sp,sp,48
    80002be8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bea:	00005517          	auipc	a0,0x5
    80002bee:	7a650513          	add	a0,a0,1958 # 80008390 <states.0+0xc8>
    80002bf2:	ffffe097          	auipc	ra,0xffffe
    80002bf6:	94a080e7          	jalr	-1718(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002bfa:	00005517          	auipc	a0,0x5
    80002bfe:	7be50513          	add	a0,a0,1982 # 800083b8 <states.0+0xf0>
    80002c02:	ffffe097          	auipc	ra,0xffffe
    80002c06:	93a080e7          	jalr	-1734(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002c0a:	85ce                	mv	a1,s3
    80002c0c:	00005517          	auipc	a0,0x5
    80002c10:	7cc50513          	add	a0,a0,1996 # 800083d8 <states.0+0x110>
    80002c14:	ffffe097          	auipc	ra,0xffffe
    80002c18:	972080e7          	jalr	-1678(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c1c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c20:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c24:	00005517          	auipc	a0,0x5
    80002c28:	7c450513          	add	a0,a0,1988 # 800083e8 <states.0+0x120>
    80002c2c:	ffffe097          	auipc	ra,0xffffe
    80002c30:	95a080e7          	jalr	-1702(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002c34:	00005517          	auipc	a0,0x5
    80002c38:	7cc50513          	add	a0,a0,1996 # 80008400 <states.0+0x138>
    80002c3c:	ffffe097          	auipc	ra,0xffffe
    80002c40:	900080e7          	jalr	-1792(ra) # 8000053c <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c44:	fffff097          	auipc	ra,0xfffff
    80002c48:	d62080e7          	jalr	-670(ra) # 800019a6 <myproc>
    80002c4c:	d541                	beqz	a0,80002bd4 <kerneltrap+0x38>
    80002c4e:	fffff097          	auipc	ra,0xfffff
    80002c52:	d58080e7          	jalr	-680(ra) # 800019a6 <myproc>
    80002c56:	4d18                	lw	a4,24(a0)
    80002c58:	4791                	li	a5,4
    80002c5a:	f6f71de3          	bne	a4,a5,80002bd4 <kerneltrap+0x38>
    yield();
    80002c5e:	fffff097          	auipc	ra,0xfffff
    80002c62:	45a080e7          	jalr	1114(ra) # 800020b8 <yield>
    80002c66:	b7bd                	j	80002bd4 <kerneltrap+0x38>

0000000080002c68 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c68:	1101                	add	sp,sp,-32
    80002c6a:	ec06                	sd	ra,24(sp)
    80002c6c:	e822                	sd	s0,16(sp)
    80002c6e:	e426                	sd	s1,8(sp)
    80002c70:	1000                	add	s0,sp,32
    80002c72:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c74:	fffff097          	auipc	ra,0xfffff
    80002c78:	d32080e7          	jalr	-718(ra) # 800019a6 <myproc>
  switch (n) {
    80002c7c:	4795                	li	a5,5
    80002c7e:	0497e163          	bltu	a5,s1,80002cc0 <argraw+0x58>
    80002c82:	048a                	sll	s1,s1,0x2
    80002c84:	00005717          	auipc	a4,0x5
    80002c88:	7b470713          	add	a4,a4,1972 # 80008438 <states.0+0x170>
    80002c8c:	94ba                	add	s1,s1,a4
    80002c8e:	409c                	lw	a5,0(s1)
    80002c90:	97ba                	add	a5,a5,a4
    80002c92:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c94:	6d3c                	ld	a5,88(a0)
    80002c96:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c98:	60e2                	ld	ra,24(sp)
    80002c9a:	6442                	ld	s0,16(sp)
    80002c9c:	64a2                	ld	s1,8(sp)
    80002c9e:	6105                	add	sp,sp,32
    80002ca0:	8082                	ret
    return p->trapframe->a1;
    80002ca2:	6d3c                	ld	a5,88(a0)
    80002ca4:	7fa8                	ld	a0,120(a5)
    80002ca6:	bfcd                	j	80002c98 <argraw+0x30>
    return p->trapframe->a2;
    80002ca8:	6d3c                	ld	a5,88(a0)
    80002caa:	63c8                	ld	a0,128(a5)
    80002cac:	b7f5                	j	80002c98 <argraw+0x30>
    return p->trapframe->a3;
    80002cae:	6d3c                	ld	a5,88(a0)
    80002cb0:	67c8                	ld	a0,136(a5)
    80002cb2:	b7dd                	j	80002c98 <argraw+0x30>
    return p->trapframe->a4;
    80002cb4:	6d3c                	ld	a5,88(a0)
    80002cb6:	6bc8                	ld	a0,144(a5)
    80002cb8:	b7c5                	j	80002c98 <argraw+0x30>
    return p->trapframe->a5;
    80002cba:	6d3c                	ld	a5,88(a0)
    80002cbc:	6fc8                	ld	a0,152(a5)
    80002cbe:	bfe9                	j	80002c98 <argraw+0x30>
  panic("argraw");
    80002cc0:	00005517          	auipc	a0,0x5
    80002cc4:	75050513          	add	a0,a0,1872 # 80008410 <states.0+0x148>
    80002cc8:	ffffe097          	auipc	ra,0xffffe
    80002ccc:	874080e7          	jalr	-1932(ra) # 8000053c <panic>

0000000080002cd0 <fetchaddr>:
{
    80002cd0:	1101                	add	sp,sp,-32
    80002cd2:	ec06                	sd	ra,24(sp)
    80002cd4:	e822                	sd	s0,16(sp)
    80002cd6:	e426                	sd	s1,8(sp)
    80002cd8:	e04a                	sd	s2,0(sp)
    80002cda:	1000                	add	s0,sp,32
    80002cdc:	84aa                	mv	s1,a0
    80002cde:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ce0:	fffff097          	auipc	ra,0xfffff
    80002ce4:	cc6080e7          	jalr	-826(ra) # 800019a6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ce8:	653c                	ld	a5,72(a0)
    80002cea:	02f4f863          	bgeu	s1,a5,80002d1a <fetchaddr+0x4a>
    80002cee:	00848713          	add	a4,s1,8
    80002cf2:	02e7e663          	bltu	a5,a4,80002d1e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cf6:	46a1                	li	a3,8
    80002cf8:	8626                	mv	a2,s1
    80002cfa:	85ca                	mv	a1,s2
    80002cfc:	6928                	ld	a0,80(a0)
    80002cfe:	fffff097          	auipc	ra,0xfffff
    80002d02:	9f4080e7          	jalr	-1548(ra) # 800016f2 <copyin>
    80002d06:	00a03533          	snez	a0,a0
    80002d0a:	40a00533          	neg	a0,a0
}
    80002d0e:	60e2                	ld	ra,24(sp)
    80002d10:	6442                	ld	s0,16(sp)
    80002d12:	64a2                	ld	s1,8(sp)
    80002d14:	6902                	ld	s2,0(sp)
    80002d16:	6105                	add	sp,sp,32
    80002d18:	8082                	ret
    return -1;
    80002d1a:	557d                	li	a0,-1
    80002d1c:	bfcd                	j	80002d0e <fetchaddr+0x3e>
    80002d1e:	557d                	li	a0,-1
    80002d20:	b7fd                	j	80002d0e <fetchaddr+0x3e>

0000000080002d22 <fetchstr>:
{
    80002d22:	7179                	add	sp,sp,-48
    80002d24:	f406                	sd	ra,40(sp)
    80002d26:	f022                	sd	s0,32(sp)
    80002d28:	ec26                	sd	s1,24(sp)
    80002d2a:	e84a                	sd	s2,16(sp)
    80002d2c:	e44e                	sd	s3,8(sp)
    80002d2e:	1800                	add	s0,sp,48
    80002d30:	892a                	mv	s2,a0
    80002d32:	84ae                	mv	s1,a1
    80002d34:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d36:	fffff097          	auipc	ra,0xfffff
    80002d3a:	c70080e7          	jalr	-912(ra) # 800019a6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d3e:	86ce                	mv	a3,s3
    80002d40:	864a                	mv	a2,s2
    80002d42:	85a6                	mv	a1,s1
    80002d44:	6928                	ld	a0,80(a0)
    80002d46:	fffff097          	auipc	ra,0xfffff
    80002d4a:	a3a080e7          	jalr	-1478(ra) # 80001780 <copyinstr>
    80002d4e:	00054e63          	bltz	a0,80002d6a <fetchstr+0x48>
  return strlen(buf);
    80002d52:	8526                	mv	a0,s1
    80002d54:	ffffe097          	auipc	ra,0xffffe
    80002d58:	0f4080e7          	jalr	244(ra) # 80000e48 <strlen>
}
    80002d5c:	70a2                	ld	ra,40(sp)
    80002d5e:	7402                	ld	s0,32(sp)
    80002d60:	64e2                	ld	s1,24(sp)
    80002d62:	6942                	ld	s2,16(sp)
    80002d64:	69a2                	ld	s3,8(sp)
    80002d66:	6145                	add	sp,sp,48
    80002d68:	8082                	ret
    return -1;
    80002d6a:	557d                	li	a0,-1
    80002d6c:	bfc5                	j	80002d5c <fetchstr+0x3a>

0000000080002d6e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d6e:	1101                	add	sp,sp,-32
    80002d70:	ec06                	sd	ra,24(sp)
    80002d72:	e822                	sd	s0,16(sp)
    80002d74:	e426                	sd	s1,8(sp)
    80002d76:	1000                	add	s0,sp,32
    80002d78:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d7a:	00000097          	auipc	ra,0x0
    80002d7e:	eee080e7          	jalr	-274(ra) # 80002c68 <argraw>
    80002d82:	c088                	sw	a0,0(s1)
  // return 0;
}
    80002d84:	60e2                	ld	ra,24(sp)
    80002d86:	6442                	ld	s0,16(sp)
    80002d88:	64a2                	ld	s1,8(sp)
    80002d8a:	6105                	add	sp,sp,32
    80002d8c:	8082                	ret

0000000080002d8e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d8e:	1101                	add	sp,sp,-32
    80002d90:	ec06                	sd	ra,24(sp)
    80002d92:	e822                	sd	s0,16(sp)
    80002d94:	e426                	sd	s1,8(sp)
    80002d96:	1000                	add	s0,sp,32
    80002d98:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d9a:	00000097          	auipc	ra,0x0
    80002d9e:	ece080e7          	jalr	-306(ra) # 80002c68 <argraw>
    80002da2:	e088                	sd	a0,0(s1)
  // return 0;
}
    80002da4:	60e2                	ld	ra,24(sp)
    80002da6:	6442                	ld	s0,16(sp)
    80002da8:	64a2                	ld	s1,8(sp)
    80002daa:	6105                	add	sp,sp,32
    80002dac:	8082                	ret

0000000080002dae <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002dae:	7179                	add	sp,sp,-48
    80002db0:	f406                	sd	ra,40(sp)
    80002db2:	f022                	sd	s0,32(sp)
    80002db4:	ec26                	sd	s1,24(sp)
    80002db6:	e84a                	sd	s2,16(sp)
    80002db8:	1800                	add	s0,sp,48
    80002dba:	84ae                	mv	s1,a1
    80002dbc:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002dbe:	fd840593          	add	a1,s0,-40
    80002dc2:	00000097          	auipc	ra,0x0
    80002dc6:	fcc080e7          	jalr	-52(ra) # 80002d8e <argaddr>
  return fetchstr(addr, buf, max);
    80002dca:	864a                	mv	a2,s2
    80002dcc:	85a6                	mv	a1,s1
    80002dce:	fd843503          	ld	a0,-40(s0)
    80002dd2:	00000097          	auipc	ra,0x0
    80002dd6:	f50080e7          	jalr	-176(ra) # 80002d22 <fetchstr>
}
    80002dda:	70a2                	ld	ra,40(sp)
    80002ddc:	7402                	ld	s0,32(sp)
    80002dde:	64e2                	ld	s1,24(sp)
    80002de0:	6942                	ld	s2,16(sp)
    80002de2:	6145                	add	sp,sp,48
    80002de4:	8082                	ret

0000000080002de6 <syscall>:
[SYS_sigreturn] sys_sigreturn,
};

void
syscall(void)
{
    80002de6:	1101                	add	sp,sp,-32
    80002de8:	ec06                	sd	ra,24(sp)
    80002dea:	e822                	sd	s0,16(sp)
    80002dec:	e426                	sd	s1,8(sp)
    80002dee:	e04a                	sd	s2,0(sp)
    80002df0:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002df2:	fffff097          	auipc	ra,0xfffff
    80002df6:	bb4080e7          	jalr	-1100(ra) # 800019a6 <myproc>
    80002dfa:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002dfc:	05853903          	ld	s2,88(a0)
    80002e00:	0a893783          	ld	a5,168(s2)
    80002e04:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e08:	37fd                	addw	a5,a5,-1
    80002e0a:	4761                	li	a4,24
    80002e0c:	00f76f63          	bltu	a4,a5,80002e2a <syscall+0x44>
    80002e10:	00369713          	sll	a4,a3,0x3
    80002e14:	00005797          	auipc	a5,0x5
    80002e18:	63c78793          	add	a5,a5,1596 # 80008450 <syscalls>
    80002e1c:	97ba                	add	a5,a5,a4
    80002e1e:	639c                	ld	a5,0(a5)
    80002e20:	c789                	beqz	a5,80002e2a <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e22:	9782                	jalr	a5
    80002e24:	06a93823          	sd	a0,112(s2)
    80002e28:	a839                	j	80002e46 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    80002e2a:	15848613          	add	a2,s1,344
    80002e2e:	588c                	lw	a1,48(s1)
    80002e30:	00005517          	auipc	a0,0x5
    80002e34:	5e850513          	add	a0,a0,1512 # 80008418 <states.0+0x150>
    80002e38:	ffffd097          	auipc	ra,0xffffd
    80002e3c:	74e080e7          	jalr	1870(ra) # 80000586 <printf>
    p->trapframe->a0 = -1;
    80002e40:	6cbc                	ld	a5,88(s1)
    80002e42:	577d                	li	a4,-1
    80002e44:	fbb8                	sd	a4,112(a5)
  }
}
    80002e46:	60e2                	ld	ra,24(sp)
    80002e48:	6442                	ld	s0,16(sp)
    80002e4a:	64a2                	ld	s1,8(sp)
    80002e4c:	6902                	ld	s2,0(sp)
    80002e4e:	6105                	add	sp,sp,32
    80002e50:	8082                	ret

0000000080002e52 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e52:	1101                	add	sp,sp,-32
    80002e54:	ec06                	sd	ra,24(sp)
    80002e56:	e822                	sd	s0,16(sp)
    80002e58:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    80002e5a:	fec40593          	add	a1,s0,-20
    80002e5e:	4501                	li	a0,0
    80002e60:	00000097          	auipc	ra,0x0
    80002e64:	f0e080e7          	jalr	-242(ra) # 80002d6e <argint>
  exit(n);
    80002e68:	fec42503          	lw	a0,-20(s0)
    80002e6c:	fffff097          	auipc	ra,0xfffff
    80002e70:	3bc080e7          	jalr	956(ra) # 80002228 <exit>
  return 0; // not reached
}
    80002e74:	4501                	li	a0,0
    80002e76:	60e2                	ld	ra,24(sp)
    80002e78:	6442                	ld	s0,16(sp)
    80002e7a:	6105                	add	sp,sp,32
    80002e7c:	8082                	ret

0000000080002e7e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e7e:	1141                	add	sp,sp,-16
    80002e80:	e406                	sd	ra,8(sp)
    80002e82:	e022                	sd	s0,0(sp)
    80002e84:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002e86:	fffff097          	auipc	ra,0xfffff
    80002e8a:	b20080e7          	jalr	-1248(ra) # 800019a6 <myproc>
}
    80002e8e:	5908                	lw	a0,48(a0)
    80002e90:	60a2                	ld	ra,8(sp)
    80002e92:	6402                	ld	s0,0(sp)
    80002e94:	0141                	add	sp,sp,16
    80002e96:	8082                	ret

0000000080002e98 <sys_fork>:

uint64
sys_fork(void)
{
    80002e98:	1141                	add	sp,sp,-16
    80002e9a:	e406                	sd	ra,8(sp)
    80002e9c:	e022                	sd	s0,0(sp)
    80002e9e:	0800                	add	s0,sp,16
  return fork();
    80002ea0:	fffff097          	auipc	ra,0xfffff
    80002ea4:	f06080e7          	jalr	-250(ra) # 80001da6 <fork>
}
    80002ea8:	60a2                	ld	ra,8(sp)
    80002eaa:	6402                	ld	s0,0(sp)
    80002eac:	0141                	add	sp,sp,16
    80002eae:	8082                	ret

0000000080002eb0 <sys_wait>:

uint64
sys_wait(void)
{
    80002eb0:	1101                	add	sp,sp,-32
    80002eb2:	ec06                	sd	ra,24(sp)
    80002eb4:	e822                	sd	s0,16(sp)
    80002eb6:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002eb8:	fe840593          	add	a1,s0,-24
    80002ebc:	4501                	li	a0,0
    80002ebe:	00000097          	auipc	ra,0x0
    80002ec2:	ed0080e7          	jalr	-304(ra) # 80002d8e <argaddr>
  return wait(p);
    80002ec6:	fe843503          	ld	a0,-24(s0)
    80002eca:	fffff097          	auipc	ra,0xfffff
    80002ece:	510080e7          	jalr	1296(ra) # 800023da <wait>
}
    80002ed2:	60e2                	ld	ra,24(sp)
    80002ed4:	6442                	ld	s0,16(sp)
    80002ed6:	6105                	add	sp,sp,32
    80002ed8:	8082                	ret

0000000080002eda <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002eda:	7179                	add	sp,sp,-48
    80002edc:	f406                	sd	ra,40(sp)
    80002ede:	f022                	sd	s0,32(sp)
    80002ee0:	ec26                	sd	s1,24(sp)
    80002ee2:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002ee4:	fdc40593          	add	a1,s0,-36
    80002ee8:	4501                	li	a0,0
    80002eea:	00000097          	auipc	ra,0x0
    80002eee:	e84080e7          	jalr	-380(ra) # 80002d6e <argint>
  addr = myproc()->sz;
    80002ef2:	fffff097          	auipc	ra,0xfffff
    80002ef6:	ab4080e7          	jalr	-1356(ra) # 800019a6 <myproc>
    80002efa:	6524                	ld	s1,72(a0)
  if (growproc(n) < 0)
    80002efc:	fdc42503          	lw	a0,-36(s0)
    80002f00:	fffff097          	auipc	ra,0xfffff
    80002f04:	e4a080e7          	jalr	-438(ra) # 80001d4a <growproc>
    80002f08:	00054863          	bltz	a0,80002f18 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002f0c:	8526                	mv	a0,s1
    80002f0e:	70a2                	ld	ra,40(sp)
    80002f10:	7402                	ld	s0,32(sp)
    80002f12:	64e2                	ld	s1,24(sp)
    80002f14:	6145                	add	sp,sp,48
    80002f16:	8082                	ret
    return -1;
    80002f18:	54fd                	li	s1,-1
    80002f1a:	bfcd                	j	80002f0c <sys_sbrk+0x32>

0000000080002f1c <sys_sleep>:

uint64
sys_sleep(void)
{
    80002f1c:	7139                	add	sp,sp,-64
    80002f1e:	fc06                	sd	ra,56(sp)
    80002f20:	f822                	sd	s0,48(sp)
    80002f22:	f426                	sd	s1,40(sp)
    80002f24:	f04a                	sd	s2,32(sp)
    80002f26:	ec4e                	sd	s3,24(sp)
    80002f28:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f2a:	fcc40593          	add	a1,s0,-52
    80002f2e:	4501                	li	a0,0
    80002f30:	00000097          	auipc	ra,0x0
    80002f34:	e3e080e7          	jalr	-450(ra) # 80002d6e <argint>
  acquire(&tickslock);
    80002f38:	00014517          	auipc	a0,0x14
    80002f3c:	67850513          	add	a0,a0,1656 # 800175b0 <tickslock>
    80002f40:	ffffe097          	auipc	ra,0xffffe
    80002f44:	c92080e7          	jalr	-878(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002f48:	00006917          	auipc	s2,0x6
    80002f4c:	9c892903          	lw	s2,-1592(s2) # 80008910 <ticks>
  while (ticks - ticks0 < n)
    80002f50:	fcc42783          	lw	a5,-52(s0)
    80002f54:	cf9d                	beqz	a5,80002f92 <sys_sleep+0x76>
    if (killed(myproc()))
    {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f56:	00014997          	auipc	s3,0x14
    80002f5a:	65a98993          	add	s3,s3,1626 # 800175b0 <tickslock>
    80002f5e:	00006497          	auipc	s1,0x6
    80002f62:	9b248493          	add	s1,s1,-1614 # 80008910 <ticks>
    if (killed(myproc()))
    80002f66:	fffff097          	auipc	ra,0xfffff
    80002f6a:	a40080e7          	jalr	-1472(ra) # 800019a6 <myproc>
    80002f6e:	fffff097          	auipc	ra,0xfffff
    80002f72:	43a080e7          	jalr	1082(ra) # 800023a8 <killed>
    80002f76:	ed15                	bnez	a0,80002fb2 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002f78:	85ce                	mv	a1,s3
    80002f7a:	8526                	mv	a0,s1
    80002f7c:	fffff097          	auipc	ra,0xfffff
    80002f80:	178080e7          	jalr	376(ra) # 800020f4 <sleep>
  while (ticks - ticks0 < n)
    80002f84:	409c                	lw	a5,0(s1)
    80002f86:	412787bb          	subw	a5,a5,s2
    80002f8a:	fcc42703          	lw	a4,-52(s0)
    80002f8e:	fce7ece3          	bltu	a5,a4,80002f66 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002f92:	00014517          	auipc	a0,0x14
    80002f96:	61e50513          	add	a0,a0,1566 # 800175b0 <tickslock>
    80002f9a:	ffffe097          	auipc	ra,0xffffe
    80002f9e:	cec080e7          	jalr	-788(ra) # 80000c86 <release>
  return 0;
    80002fa2:	4501                	li	a0,0
}
    80002fa4:	70e2                	ld	ra,56(sp)
    80002fa6:	7442                	ld	s0,48(sp)
    80002fa8:	74a2                	ld	s1,40(sp)
    80002faa:	7902                	ld	s2,32(sp)
    80002fac:	69e2                	ld	s3,24(sp)
    80002fae:	6121                	add	sp,sp,64
    80002fb0:	8082                	ret
      release(&tickslock);
    80002fb2:	00014517          	auipc	a0,0x14
    80002fb6:	5fe50513          	add	a0,a0,1534 # 800175b0 <tickslock>
    80002fba:	ffffe097          	auipc	ra,0xffffe
    80002fbe:	ccc080e7          	jalr	-820(ra) # 80000c86 <release>
      return -1;
    80002fc2:	557d                	li	a0,-1
    80002fc4:	b7c5                	j	80002fa4 <sys_sleep+0x88>

0000000080002fc6 <sys_kill>:

uint64
sys_kill(void)
{
    80002fc6:	1101                	add	sp,sp,-32
    80002fc8:	ec06                	sd	ra,24(sp)
    80002fca:	e822                	sd	s0,16(sp)
    80002fcc:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    80002fce:	fec40593          	add	a1,s0,-20
    80002fd2:	4501                	li	a0,0
    80002fd4:	00000097          	auipc	ra,0x0
    80002fd8:	d9a080e7          	jalr	-614(ra) # 80002d6e <argint>
  return kill(pid);
    80002fdc:	fec42503          	lw	a0,-20(s0)
    80002fe0:	fffff097          	auipc	ra,0xfffff
    80002fe4:	32a080e7          	jalr	810(ra) # 8000230a <kill>
}
    80002fe8:	60e2                	ld	ra,24(sp)
    80002fea:	6442                	ld	s0,16(sp)
    80002fec:	6105                	add	sp,sp,32
    80002fee:	8082                	ret

0000000080002ff0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ff0:	1101                	add	sp,sp,-32
    80002ff2:	ec06                	sd	ra,24(sp)
    80002ff4:	e822                	sd	s0,16(sp)
    80002ff6:	e426                	sd	s1,8(sp)
    80002ff8:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ffa:	00014517          	auipc	a0,0x14
    80002ffe:	5b650513          	add	a0,a0,1462 # 800175b0 <tickslock>
    80003002:	ffffe097          	auipc	ra,0xffffe
    80003006:	bd0080e7          	jalr	-1072(ra) # 80000bd2 <acquire>
  xticks = ticks;
    8000300a:	00006497          	auipc	s1,0x6
    8000300e:	9064a483          	lw	s1,-1786(s1) # 80008910 <ticks>
  release(&tickslock);
    80003012:	00014517          	auipc	a0,0x14
    80003016:	59e50513          	add	a0,a0,1438 # 800175b0 <tickslock>
    8000301a:	ffffe097          	auipc	ra,0xffffe
    8000301e:	c6c080e7          	jalr	-916(ra) # 80000c86 <release>
  return xticks;
}
    80003022:	02049513          	sll	a0,s1,0x20
    80003026:	9101                	srl	a0,a0,0x20
    80003028:	60e2                	ld	ra,24(sp)
    8000302a:	6442                	ld	s0,16(sp)
    8000302c:	64a2                	ld	s1,8(sp)
    8000302e:	6105                	add	sp,sp,32
    80003030:	8082                	ret

0000000080003032 <sys_waitx>:

uint64
sys_waitx(void)
{
    80003032:	7139                	add	sp,sp,-64
    80003034:	fc06                	sd	ra,56(sp)
    80003036:	f822                	sd	s0,48(sp)
    80003038:	f426                	sd	s1,40(sp)
    8000303a:	f04a                	sd	s2,32(sp)
    8000303c:	0080                	add	s0,sp,64
  uint64 addr, addr1, addr2;
  uint wtime, rtime;
  argaddr(0, &addr);
    8000303e:	fd840593          	add	a1,s0,-40
    80003042:	4501                	li	a0,0
    80003044:	00000097          	auipc	ra,0x0
    80003048:	d4a080e7          	jalr	-694(ra) # 80002d8e <argaddr>
  argaddr(1, &addr1); // user virtual memory
    8000304c:	fd040593          	add	a1,s0,-48
    80003050:	4505                	li	a0,1
    80003052:	00000097          	auipc	ra,0x0
    80003056:	d3c080e7          	jalr	-708(ra) # 80002d8e <argaddr>
  argaddr(2, &addr2);
    8000305a:	fc840593          	add	a1,s0,-56
    8000305e:	4509                	li	a0,2
    80003060:	00000097          	auipc	ra,0x0
    80003064:	d2e080e7          	jalr	-722(ra) # 80002d8e <argaddr>
  int ret = waitx(addr, &wtime, &rtime);
    80003068:	fc040613          	add	a2,s0,-64
    8000306c:	fc440593          	add	a1,s0,-60
    80003070:	fd843503          	ld	a0,-40(s0)
    80003074:	fffff097          	auipc	ra,0xfffff
    80003078:	5f0080e7          	jalr	1520(ra) # 80002664 <waitx>
    8000307c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000307e:	fffff097          	auipc	ra,0xfffff
    80003082:	928080e7          	jalr	-1752(ra) # 800019a6 <myproc>
    80003086:	84aa                	mv	s1,a0
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    80003088:	4691                	li	a3,4
    8000308a:	fc440613          	add	a2,s0,-60
    8000308e:	fd043583          	ld	a1,-48(s0)
    80003092:	6928                	ld	a0,80(a0)
    80003094:	ffffe097          	auipc	ra,0xffffe
    80003098:	5d2080e7          	jalr	1490(ra) # 80001666 <copyout>
    return -1;
    8000309c:	57fd                	li	a5,-1
  if (copyout(p->pagetable, addr1, (char *)&wtime, sizeof(int)) < 0)
    8000309e:	00054f63          	bltz	a0,800030bc <sys_waitx+0x8a>
  if (copyout(p->pagetable, addr2, (char *)&rtime, sizeof(int)) < 0)
    800030a2:	4691                	li	a3,4
    800030a4:	fc040613          	add	a2,s0,-64
    800030a8:	fc843583          	ld	a1,-56(s0)
    800030ac:	68a8                	ld	a0,80(s1)
    800030ae:	ffffe097          	auipc	ra,0xffffe
    800030b2:	5b8080e7          	jalr	1464(ra) # 80001666 <copyout>
    800030b6:	00054a63          	bltz	a0,800030ca <sys_waitx+0x98>
    return -1;
  return ret;
    800030ba:	87ca                	mv	a5,s2
}
    800030bc:	853e                	mv	a0,a5
    800030be:	70e2                	ld	ra,56(sp)
    800030c0:	7442                	ld	s0,48(sp)
    800030c2:	74a2                	ld	s1,40(sp)
    800030c4:	7902                	ld	s2,32(sp)
    800030c6:	6121                	add	sp,sp,64
    800030c8:	8082                	ret
    return -1;
    800030ca:	57fd                	li	a5,-1
    800030cc:	bfc5                	j	800030bc <sys_waitx+0x8a>

00000000800030ce <sys_getreadcount>:

// returns total number of calls made to read() system call
uint64
sys_getreadcount(void)
{
    800030ce:	1101                	add	sp,sp,-32
    800030d0:	ec06                	sd	ra,24(sp)
    800030d2:	e822                	sd	s0,16(sp)
    800030d4:	e426                	sd	s1,8(sp)
    800030d6:	1000                	add	s0,sp,32
  uint64 xreadcount;
  acquire(&readcountlock); // Acquire the lock to protect readcount
    800030d8:	0001e517          	auipc	a0,0x1e
    800030dc:	72050513          	add	a0,a0,1824 # 800217f8 <readcountlock>
    800030e0:	ffffe097          	auipc	ra,0xffffe
    800030e4:	af2080e7          	jalr	-1294(ra) # 80000bd2 <acquire>
  xreadcount = readcount; // Read the readcount variable
    800030e8:	00006497          	auipc	s1,0x6
    800030ec:	82c4e483          	lwu	s1,-2004(s1) # 80008914 <readcount>
  release(&readcountlock); // Release the lock
    800030f0:	0001e517          	auipc	a0,0x1e
    800030f4:	70850513          	add	a0,a0,1800 # 800217f8 <readcountlock>
    800030f8:	ffffe097          	auipc	ra,0xffffe
    800030fc:	b8e080e7          	jalr	-1138(ra) # 80000c86 <release>
  return xreadcount;
}
    80003100:	8526                	mv	a0,s1
    80003102:	60e2                	ld	ra,24(sp)
    80003104:	6442                	ld	s0,16(sp)
    80003106:	64a2                	ld	s1,8(sp)
    80003108:	6105                	add	sp,sp,32
    8000310a:	8082                	ret

000000008000310c <sys_sigalarm>:

uint64 sys_sigalarm(void) {
    8000310c:	1101                	add	sp,sp,-32
    8000310e:	ec06                	sd	ra,24(sp)
    80003110:	e822                	sd	s0,16(sp)
    80003112:	1000                	add	s0,sp,32
  int interval;
  uint64 fn;
  argint(0, &interval);
    80003114:	fec40593          	add	a1,s0,-20
    80003118:	4501                	li	a0,0
    8000311a:	00000097          	auipc	ra,0x0
    8000311e:	c54080e7          	jalr	-940(ra) # 80002d6e <argint>
  argaddr(1, &fn);
    80003122:	fe040593          	add	a1,s0,-32
    80003126:	4505                	li	a0,1
    80003128:	00000097          	auipc	ra,0x0
    8000312c:	c66080e7          	jalr	-922(ra) # 80002d8e <argaddr>

  struct proc *p = myproc();
    80003130:	fffff097          	auipc	ra,0xfffff
    80003134:	876080e7          	jalr	-1930(ra) # 800019a6 <myproc>

  p->sigalarm_status = 0;
    80003138:	18052823          	sw	zero,400(a0)
  p->interval = interval;
    8000313c:	fec42783          	lw	a5,-20(s0)
    80003140:	18f52023          	sw	a5,384(a0)
  p->now_ticks = 0;
    80003144:	18052223          	sw	zero,388(a0)
  p->handler = fn;
    80003148:	fe043783          	ld	a5,-32(s0)
    8000314c:	16f53c23          	sd	a5,376(a0)

  return 0;
}
    80003150:	4501                	li	a0,0
    80003152:	60e2                	ld	ra,24(sp)
    80003154:	6442                	ld	s0,16(sp)
    80003156:	6105                	add	sp,sp,32
    80003158:	8082                	ret

000000008000315a <sys_sigreturn>:

uint64 sys_sigreturn(void) {
    8000315a:	1101                	add	sp,sp,-32
    8000315c:	ec06                	sd	ra,24(sp)
    8000315e:	e822                	sd	s0,16(sp)
    80003160:	e426                	sd	s1,8(sp)
    80003162:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    80003164:	fffff097          	auipc	ra,0xfffff
    80003168:	842080e7          	jalr	-1982(ra) # 800019a6 <myproc>
    8000316c:	84aa                	mv	s1,a0

  // Restore Kernel Values
  memmove(p->trapframe, p->alarm_trapframe, PGSIZE);
    8000316e:	6605                	lui	a2,0x1
    80003170:	18853583          	ld	a1,392(a0)
    80003174:	6d28                	ld	a0,88(a0)
    80003176:	ffffe097          	auipc	ra,0xffffe
    8000317a:	bb4080e7          	jalr	-1100(ra) # 80000d2a <memmove>
  kfree(p->alarm_trapframe);
    8000317e:	1884b503          	ld	a0,392(s1)
    80003182:	ffffe097          	auipc	ra,0xffffe
    80003186:	862080e7          	jalr	-1950(ra) # 800009e4 <kfree>

  p->sigalarm_status = 0;
    8000318a:	1804a823          	sw	zero,400(s1)
  p->alarm_trapframe = 0;
    8000318e:	1804b423          	sd	zero,392(s1)
  p->now_ticks = 0;
    80003192:	1804a223          	sw	zero,388(s1)
  usertrapret();
    80003196:	fffff097          	auipc	ra,0xfffff
    8000319a:	722080e7          	jalr	1826(ra) # 800028b8 <usertrapret>
  return 0;
}
    8000319e:	4501                	li	a0,0
    800031a0:	60e2                	ld	ra,24(sp)
    800031a2:	6442                	ld	s0,16(sp)
    800031a4:	64a2                	ld	s1,8(sp)
    800031a6:	6105                	add	sp,sp,32
    800031a8:	8082                	ret

00000000800031aa <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800031aa:	7179                	add	sp,sp,-48
    800031ac:	f406                	sd	ra,40(sp)
    800031ae:	f022                	sd	s0,32(sp)
    800031b0:	ec26                	sd	s1,24(sp)
    800031b2:	e84a                	sd	s2,16(sp)
    800031b4:	e44e                	sd	s3,8(sp)
    800031b6:	e052                	sd	s4,0(sp)
    800031b8:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800031ba:	00005597          	auipc	a1,0x5
    800031be:	36658593          	add	a1,a1,870 # 80008520 <syscalls+0xd0>
    800031c2:	00014517          	auipc	a0,0x14
    800031c6:	40650513          	add	a0,a0,1030 # 800175c8 <bcache>
    800031ca:	ffffe097          	auipc	ra,0xffffe
    800031ce:	978080e7          	jalr	-1672(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800031d2:	0001c797          	auipc	a5,0x1c
    800031d6:	3f678793          	add	a5,a5,1014 # 8001f5c8 <bcache+0x8000>
    800031da:	0001c717          	auipc	a4,0x1c
    800031de:	65670713          	add	a4,a4,1622 # 8001f830 <bcache+0x8268>
    800031e2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800031e6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800031ea:	00014497          	auipc	s1,0x14
    800031ee:	3f648493          	add	s1,s1,1014 # 800175e0 <bcache+0x18>
    b->next = bcache.head.next;
    800031f2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800031f4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800031f6:	00005a17          	auipc	s4,0x5
    800031fa:	332a0a13          	add	s4,s4,818 # 80008528 <syscalls+0xd8>
    b->next = bcache.head.next;
    800031fe:	2b893783          	ld	a5,696(s2)
    80003202:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003204:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003208:	85d2                	mv	a1,s4
    8000320a:	01048513          	add	a0,s1,16
    8000320e:	00001097          	auipc	ra,0x1
    80003212:	496080e7          	jalr	1174(ra) # 800046a4 <initsleeplock>
    bcache.head.next->prev = b;
    80003216:	2b893783          	ld	a5,696(s2)
    8000321a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000321c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003220:	45848493          	add	s1,s1,1112
    80003224:	fd349de3          	bne	s1,s3,800031fe <binit+0x54>
  }
}
    80003228:	70a2                	ld	ra,40(sp)
    8000322a:	7402                	ld	s0,32(sp)
    8000322c:	64e2                	ld	s1,24(sp)
    8000322e:	6942                	ld	s2,16(sp)
    80003230:	69a2                	ld	s3,8(sp)
    80003232:	6a02                	ld	s4,0(sp)
    80003234:	6145                	add	sp,sp,48
    80003236:	8082                	ret

0000000080003238 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003238:	7179                	add	sp,sp,-48
    8000323a:	f406                	sd	ra,40(sp)
    8000323c:	f022                	sd	s0,32(sp)
    8000323e:	ec26                	sd	s1,24(sp)
    80003240:	e84a                	sd	s2,16(sp)
    80003242:	e44e                	sd	s3,8(sp)
    80003244:	1800                	add	s0,sp,48
    80003246:	892a                	mv	s2,a0
    80003248:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000324a:	00014517          	auipc	a0,0x14
    8000324e:	37e50513          	add	a0,a0,894 # 800175c8 <bcache>
    80003252:	ffffe097          	auipc	ra,0xffffe
    80003256:	980080e7          	jalr	-1664(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000325a:	0001c497          	auipc	s1,0x1c
    8000325e:	6264b483          	ld	s1,1574(s1) # 8001f880 <bcache+0x82b8>
    80003262:	0001c797          	auipc	a5,0x1c
    80003266:	5ce78793          	add	a5,a5,1486 # 8001f830 <bcache+0x8268>
    8000326a:	02f48f63          	beq	s1,a5,800032a8 <bread+0x70>
    8000326e:	873e                	mv	a4,a5
    80003270:	a021                	j	80003278 <bread+0x40>
    80003272:	68a4                	ld	s1,80(s1)
    80003274:	02e48a63          	beq	s1,a4,800032a8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003278:	449c                	lw	a5,8(s1)
    8000327a:	ff279ce3          	bne	a5,s2,80003272 <bread+0x3a>
    8000327e:	44dc                	lw	a5,12(s1)
    80003280:	ff3799e3          	bne	a5,s3,80003272 <bread+0x3a>
      b->refcnt++;
    80003284:	40bc                	lw	a5,64(s1)
    80003286:	2785                	addw	a5,a5,1
    80003288:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000328a:	00014517          	auipc	a0,0x14
    8000328e:	33e50513          	add	a0,a0,830 # 800175c8 <bcache>
    80003292:	ffffe097          	auipc	ra,0xffffe
    80003296:	9f4080e7          	jalr	-1548(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    8000329a:	01048513          	add	a0,s1,16
    8000329e:	00001097          	auipc	ra,0x1
    800032a2:	440080e7          	jalr	1088(ra) # 800046de <acquiresleep>
      return b;
    800032a6:	a8b9                	j	80003304 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800032a8:	0001c497          	auipc	s1,0x1c
    800032ac:	5d04b483          	ld	s1,1488(s1) # 8001f878 <bcache+0x82b0>
    800032b0:	0001c797          	auipc	a5,0x1c
    800032b4:	58078793          	add	a5,a5,1408 # 8001f830 <bcache+0x8268>
    800032b8:	00f48863          	beq	s1,a5,800032c8 <bread+0x90>
    800032bc:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800032be:	40bc                	lw	a5,64(s1)
    800032c0:	cf81                	beqz	a5,800032d8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800032c2:	64a4                	ld	s1,72(s1)
    800032c4:	fee49de3          	bne	s1,a4,800032be <bread+0x86>
  panic("bget: no buffers");
    800032c8:	00005517          	auipc	a0,0x5
    800032cc:	26850513          	add	a0,a0,616 # 80008530 <syscalls+0xe0>
    800032d0:	ffffd097          	auipc	ra,0xffffd
    800032d4:	26c080e7          	jalr	620(ra) # 8000053c <panic>
      b->dev = dev;
    800032d8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800032dc:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800032e0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800032e4:	4785                	li	a5,1
    800032e6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800032e8:	00014517          	auipc	a0,0x14
    800032ec:	2e050513          	add	a0,a0,736 # 800175c8 <bcache>
    800032f0:	ffffe097          	auipc	ra,0xffffe
    800032f4:	996080e7          	jalr	-1642(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    800032f8:	01048513          	add	a0,s1,16
    800032fc:	00001097          	auipc	ra,0x1
    80003300:	3e2080e7          	jalr	994(ra) # 800046de <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003304:	409c                	lw	a5,0(s1)
    80003306:	cb89                	beqz	a5,80003318 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003308:	8526                	mv	a0,s1
    8000330a:	70a2                	ld	ra,40(sp)
    8000330c:	7402                	ld	s0,32(sp)
    8000330e:	64e2                	ld	s1,24(sp)
    80003310:	6942                	ld	s2,16(sp)
    80003312:	69a2                	ld	s3,8(sp)
    80003314:	6145                	add	sp,sp,48
    80003316:	8082                	ret
    virtio_disk_rw(b, 0);
    80003318:	4581                	li	a1,0
    8000331a:	8526                	mv	a0,s1
    8000331c:	00003097          	auipc	ra,0x3
    80003320:	fc6080e7          	jalr	-58(ra) # 800062e2 <virtio_disk_rw>
    b->valid = 1;
    80003324:	4785                	li	a5,1
    80003326:	c09c                	sw	a5,0(s1)
  return b;
    80003328:	b7c5                	j	80003308 <bread+0xd0>

000000008000332a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000332a:	1101                	add	sp,sp,-32
    8000332c:	ec06                	sd	ra,24(sp)
    8000332e:	e822                	sd	s0,16(sp)
    80003330:	e426                	sd	s1,8(sp)
    80003332:	1000                	add	s0,sp,32
    80003334:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003336:	0541                	add	a0,a0,16
    80003338:	00001097          	auipc	ra,0x1
    8000333c:	440080e7          	jalr	1088(ra) # 80004778 <holdingsleep>
    80003340:	cd01                	beqz	a0,80003358 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003342:	4585                	li	a1,1
    80003344:	8526                	mv	a0,s1
    80003346:	00003097          	auipc	ra,0x3
    8000334a:	f9c080e7          	jalr	-100(ra) # 800062e2 <virtio_disk_rw>
}
    8000334e:	60e2                	ld	ra,24(sp)
    80003350:	6442                	ld	s0,16(sp)
    80003352:	64a2                	ld	s1,8(sp)
    80003354:	6105                	add	sp,sp,32
    80003356:	8082                	ret
    panic("bwrite");
    80003358:	00005517          	auipc	a0,0x5
    8000335c:	1f050513          	add	a0,a0,496 # 80008548 <syscalls+0xf8>
    80003360:	ffffd097          	auipc	ra,0xffffd
    80003364:	1dc080e7          	jalr	476(ra) # 8000053c <panic>

0000000080003368 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003368:	1101                	add	sp,sp,-32
    8000336a:	ec06                	sd	ra,24(sp)
    8000336c:	e822                	sd	s0,16(sp)
    8000336e:	e426                	sd	s1,8(sp)
    80003370:	e04a                	sd	s2,0(sp)
    80003372:	1000                	add	s0,sp,32
    80003374:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003376:	01050913          	add	s2,a0,16
    8000337a:	854a                	mv	a0,s2
    8000337c:	00001097          	auipc	ra,0x1
    80003380:	3fc080e7          	jalr	1020(ra) # 80004778 <holdingsleep>
    80003384:	c925                	beqz	a0,800033f4 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003386:	854a                	mv	a0,s2
    80003388:	00001097          	auipc	ra,0x1
    8000338c:	3ac080e7          	jalr	940(ra) # 80004734 <releasesleep>

  acquire(&bcache.lock);
    80003390:	00014517          	auipc	a0,0x14
    80003394:	23850513          	add	a0,a0,568 # 800175c8 <bcache>
    80003398:	ffffe097          	auipc	ra,0xffffe
    8000339c:	83a080e7          	jalr	-1990(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800033a0:	40bc                	lw	a5,64(s1)
    800033a2:	37fd                	addw	a5,a5,-1
    800033a4:	0007871b          	sext.w	a4,a5
    800033a8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800033aa:	e71d                	bnez	a4,800033d8 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800033ac:	68b8                	ld	a4,80(s1)
    800033ae:	64bc                	ld	a5,72(s1)
    800033b0:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800033b2:	68b8                	ld	a4,80(s1)
    800033b4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800033b6:	0001c797          	auipc	a5,0x1c
    800033ba:	21278793          	add	a5,a5,530 # 8001f5c8 <bcache+0x8000>
    800033be:	2b87b703          	ld	a4,696(a5)
    800033c2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800033c4:	0001c717          	auipc	a4,0x1c
    800033c8:	46c70713          	add	a4,a4,1132 # 8001f830 <bcache+0x8268>
    800033cc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800033ce:	2b87b703          	ld	a4,696(a5)
    800033d2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800033d4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800033d8:	00014517          	auipc	a0,0x14
    800033dc:	1f050513          	add	a0,a0,496 # 800175c8 <bcache>
    800033e0:	ffffe097          	auipc	ra,0xffffe
    800033e4:	8a6080e7          	jalr	-1882(ra) # 80000c86 <release>
}
    800033e8:	60e2                	ld	ra,24(sp)
    800033ea:	6442                	ld	s0,16(sp)
    800033ec:	64a2                	ld	s1,8(sp)
    800033ee:	6902                	ld	s2,0(sp)
    800033f0:	6105                	add	sp,sp,32
    800033f2:	8082                	ret
    panic("brelse");
    800033f4:	00005517          	auipc	a0,0x5
    800033f8:	15c50513          	add	a0,a0,348 # 80008550 <syscalls+0x100>
    800033fc:	ffffd097          	auipc	ra,0xffffd
    80003400:	140080e7          	jalr	320(ra) # 8000053c <panic>

0000000080003404 <bpin>:

void
bpin(struct buf *b) {
    80003404:	1101                	add	sp,sp,-32
    80003406:	ec06                	sd	ra,24(sp)
    80003408:	e822                	sd	s0,16(sp)
    8000340a:	e426                	sd	s1,8(sp)
    8000340c:	1000                	add	s0,sp,32
    8000340e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003410:	00014517          	auipc	a0,0x14
    80003414:	1b850513          	add	a0,a0,440 # 800175c8 <bcache>
    80003418:	ffffd097          	auipc	ra,0xffffd
    8000341c:	7ba080e7          	jalr	1978(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80003420:	40bc                	lw	a5,64(s1)
    80003422:	2785                	addw	a5,a5,1
    80003424:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003426:	00014517          	auipc	a0,0x14
    8000342a:	1a250513          	add	a0,a0,418 # 800175c8 <bcache>
    8000342e:	ffffe097          	auipc	ra,0xffffe
    80003432:	858080e7          	jalr	-1960(ra) # 80000c86 <release>
}
    80003436:	60e2                	ld	ra,24(sp)
    80003438:	6442                	ld	s0,16(sp)
    8000343a:	64a2                	ld	s1,8(sp)
    8000343c:	6105                	add	sp,sp,32
    8000343e:	8082                	ret

0000000080003440 <bunpin>:

void
bunpin(struct buf *b) {
    80003440:	1101                	add	sp,sp,-32
    80003442:	ec06                	sd	ra,24(sp)
    80003444:	e822                	sd	s0,16(sp)
    80003446:	e426                	sd	s1,8(sp)
    80003448:	1000                	add	s0,sp,32
    8000344a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000344c:	00014517          	auipc	a0,0x14
    80003450:	17c50513          	add	a0,a0,380 # 800175c8 <bcache>
    80003454:	ffffd097          	auipc	ra,0xffffd
    80003458:	77e080e7          	jalr	1918(ra) # 80000bd2 <acquire>
  b->refcnt--;
    8000345c:	40bc                	lw	a5,64(s1)
    8000345e:	37fd                	addw	a5,a5,-1
    80003460:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003462:	00014517          	auipc	a0,0x14
    80003466:	16650513          	add	a0,a0,358 # 800175c8 <bcache>
    8000346a:	ffffe097          	auipc	ra,0xffffe
    8000346e:	81c080e7          	jalr	-2020(ra) # 80000c86 <release>
}
    80003472:	60e2                	ld	ra,24(sp)
    80003474:	6442                	ld	s0,16(sp)
    80003476:	64a2                	ld	s1,8(sp)
    80003478:	6105                	add	sp,sp,32
    8000347a:	8082                	ret

000000008000347c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000347c:	1101                	add	sp,sp,-32
    8000347e:	ec06                	sd	ra,24(sp)
    80003480:	e822                	sd	s0,16(sp)
    80003482:	e426                	sd	s1,8(sp)
    80003484:	e04a                	sd	s2,0(sp)
    80003486:	1000                	add	s0,sp,32
    80003488:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000348a:	00d5d59b          	srlw	a1,a1,0xd
    8000348e:	0001d797          	auipc	a5,0x1d
    80003492:	8167a783          	lw	a5,-2026(a5) # 8001fca4 <sb+0x1c>
    80003496:	9dbd                	addw	a1,a1,a5
    80003498:	00000097          	auipc	ra,0x0
    8000349c:	da0080e7          	jalr	-608(ra) # 80003238 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800034a0:	0074f713          	and	a4,s1,7
    800034a4:	4785                	li	a5,1
    800034a6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800034aa:	14ce                	sll	s1,s1,0x33
    800034ac:	90d9                	srl	s1,s1,0x36
    800034ae:	00950733          	add	a4,a0,s1
    800034b2:	05874703          	lbu	a4,88(a4)
    800034b6:	00e7f6b3          	and	a3,a5,a4
    800034ba:	c69d                	beqz	a3,800034e8 <bfree+0x6c>
    800034bc:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800034be:	94aa                	add	s1,s1,a0
    800034c0:	fff7c793          	not	a5,a5
    800034c4:	8f7d                	and	a4,a4,a5
    800034c6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800034ca:	00001097          	auipc	ra,0x1
    800034ce:	0f6080e7          	jalr	246(ra) # 800045c0 <log_write>
  brelse(bp);
    800034d2:	854a                	mv	a0,s2
    800034d4:	00000097          	auipc	ra,0x0
    800034d8:	e94080e7          	jalr	-364(ra) # 80003368 <brelse>
}
    800034dc:	60e2                	ld	ra,24(sp)
    800034de:	6442                	ld	s0,16(sp)
    800034e0:	64a2                	ld	s1,8(sp)
    800034e2:	6902                	ld	s2,0(sp)
    800034e4:	6105                	add	sp,sp,32
    800034e6:	8082                	ret
    panic("freeing free block");
    800034e8:	00005517          	auipc	a0,0x5
    800034ec:	07050513          	add	a0,a0,112 # 80008558 <syscalls+0x108>
    800034f0:	ffffd097          	auipc	ra,0xffffd
    800034f4:	04c080e7          	jalr	76(ra) # 8000053c <panic>

00000000800034f8 <balloc>:
{
    800034f8:	711d                	add	sp,sp,-96
    800034fa:	ec86                	sd	ra,88(sp)
    800034fc:	e8a2                	sd	s0,80(sp)
    800034fe:	e4a6                	sd	s1,72(sp)
    80003500:	e0ca                	sd	s2,64(sp)
    80003502:	fc4e                	sd	s3,56(sp)
    80003504:	f852                	sd	s4,48(sp)
    80003506:	f456                	sd	s5,40(sp)
    80003508:	f05a                	sd	s6,32(sp)
    8000350a:	ec5e                	sd	s7,24(sp)
    8000350c:	e862                	sd	s8,16(sp)
    8000350e:	e466                	sd	s9,8(sp)
    80003510:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003512:	0001c797          	auipc	a5,0x1c
    80003516:	77a7a783          	lw	a5,1914(a5) # 8001fc8c <sb+0x4>
    8000351a:	cff5                	beqz	a5,80003616 <balloc+0x11e>
    8000351c:	8baa                	mv	s7,a0
    8000351e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003520:	0001cb17          	auipc	s6,0x1c
    80003524:	768b0b13          	add	s6,s6,1896 # 8001fc88 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003528:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000352a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000352c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000352e:	6c89                	lui	s9,0x2
    80003530:	a061                	j	800035b8 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003532:	97ca                	add	a5,a5,s2
    80003534:	8e55                	or	a2,a2,a3
    80003536:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000353a:	854a                	mv	a0,s2
    8000353c:	00001097          	auipc	ra,0x1
    80003540:	084080e7          	jalr	132(ra) # 800045c0 <log_write>
        brelse(bp);
    80003544:	854a                	mv	a0,s2
    80003546:	00000097          	auipc	ra,0x0
    8000354a:	e22080e7          	jalr	-478(ra) # 80003368 <brelse>
  bp = bread(dev, bno);
    8000354e:	85a6                	mv	a1,s1
    80003550:	855e                	mv	a0,s7
    80003552:	00000097          	auipc	ra,0x0
    80003556:	ce6080e7          	jalr	-794(ra) # 80003238 <bread>
    8000355a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000355c:	40000613          	li	a2,1024
    80003560:	4581                	li	a1,0
    80003562:	05850513          	add	a0,a0,88
    80003566:	ffffd097          	auipc	ra,0xffffd
    8000356a:	768080e7          	jalr	1896(ra) # 80000cce <memset>
  log_write(bp);
    8000356e:	854a                	mv	a0,s2
    80003570:	00001097          	auipc	ra,0x1
    80003574:	050080e7          	jalr	80(ra) # 800045c0 <log_write>
  brelse(bp);
    80003578:	854a                	mv	a0,s2
    8000357a:	00000097          	auipc	ra,0x0
    8000357e:	dee080e7          	jalr	-530(ra) # 80003368 <brelse>
}
    80003582:	8526                	mv	a0,s1
    80003584:	60e6                	ld	ra,88(sp)
    80003586:	6446                	ld	s0,80(sp)
    80003588:	64a6                	ld	s1,72(sp)
    8000358a:	6906                	ld	s2,64(sp)
    8000358c:	79e2                	ld	s3,56(sp)
    8000358e:	7a42                	ld	s4,48(sp)
    80003590:	7aa2                	ld	s5,40(sp)
    80003592:	7b02                	ld	s6,32(sp)
    80003594:	6be2                	ld	s7,24(sp)
    80003596:	6c42                	ld	s8,16(sp)
    80003598:	6ca2                	ld	s9,8(sp)
    8000359a:	6125                	add	sp,sp,96
    8000359c:	8082                	ret
    brelse(bp);
    8000359e:	854a                	mv	a0,s2
    800035a0:	00000097          	auipc	ra,0x0
    800035a4:	dc8080e7          	jalr	-568(ra) # 80003368 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800035a8:	015c87bb          	addw	a5,s9,s5
    800035ac:	00078a9b          	sext.w	s5,a5
    800035b0:	004b2703          	lw	a4,4(s6)
    800035b4:	06eaf163          	bgeu	s5,a4,80003616 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800035b8:	41fad79b          	sraw	a5,s5,0x1f
    800035bc:	0137d79b          	srlw	a5,a5,0x13
    800035c0:	015787bb          	addw	a5,a5,s5
    800035c4:	40d7d79b          	sraw	a5,a5,0xd
    800035c8:	01cb2583          	lw	a1,28(s6)
    800035cc:	9dbd                	addw	a1,a1,a5
    800035ce:	855e                	mv	a0,s7
    800035d0:	00000097          	auipc	ra,0x0
    800035d4:	c68080e7          	jalr	-920(ra) # 80003238 <bread>
    800035d8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035da:	004b2503          	lw	a0,4(s6)
    800035de:	000a849b          	sext.w	s1,s5
    800035e2:	8762                	mv	a4,s8
    800035e4:	faa4fde3          	bgeu	s1,a0,8000359e <balloc+0xa6>
      m = 1 << (bi % 8);
    800035e8:	00777693          	and	a3,a4,7
    800035ec:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800035f0:	41f7579b          	sraw	a5,a4,0x1f
    800035f4:	01d7d79b          	srlw	a5,a5,0x1d
    800035f8:	9fb9                	addw	a5,a5,a4
    800035fa:	4037d79b          	sraw	a5,a5,0x3
    800035fe:	00f90633          	add	a2,s2,a5
    80003602:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80003606:	00c6f5b3          	and	a1,a3,a2
    8000360a:	d585                	beqz	a1,80003532 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000360c:	2705                	addw	a4,a4,1
    8000360e:	2485                	addw	s1,s1,1
    80003610:	fd471ae3          	bne	a4,s4,800035e4 <balloc+0xec>
    80003614:	b769                	j	8000359e <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003616:	00005517          	auipc	a0,0x5
    8000361a:	f5a50513          	add	a0,a0,-166 # 80008570 <syscalls+0x120>
    8000361e:	ffffd097          	auipc	ra,0xffffd
    80003622:	f68080e7          	jalr	-152(ra) # 80000586 <printf>
  return 0;
    80003626:	4481                	li	s1,0
    80003628:	bfa9                	j	80003582 <balloc+0x8a>

000000008000362a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000362a:	7179                	add	sp,sp,-48
    8000362c:	f406                	sd	ra,40(sp)
    8000362e:	f022                	sd	s0,32(sp)
    80003630:	ec26                	sd	s1,24(sp)
    80003632:	e84a                	sd	s2,16(sp)
    80003634:	e44e                	sd	s3,8(sp)
    80003636:	e052                	sd	s4,0(sp)
    80003638:	1800                	add	s0,sp,48
    8000363a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000363c:	47ad                	li	a5,11
    8000363e:	02b7e863          	bltu	a5,a1,8000366e <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003642:	02059793          	sll	a5,a1,0x20
    80003646:	01e7d593          	srl	a1,a5,0x1e
    8000364a:	00b504b3          	add	s1,a0,a1
    8000364e:	0504a903          	lw	s2,80(s1)
    80003652:	06091e63          	bnez	s2,800036ce <bmap+0xa4>
      addr = balloc(ip->dev);
    80003656:	4108                	lw	a0,0(a0)
    80003658:	00000097          	auipc	ra,0x0
    8000365c:	ea0080e7          	jalr	-352(ra) # 800034f8 <balloc>
    80003660:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003664:	06090563          	beqz	s2,800036ce <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003668:	0524a823          	sw	s2,80(s1)
    8000366c:	a08d                	j	800036ce <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000366e:	ff45849b          	addw	s1,a1,-12
    80003672:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003676:	0ff00793          	li	a5,255
    8000367a:	08e7e563          	bltu	a5,a4,80003704 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000367e:	08052903          	lw	s2,128(a0)
    80003682:	00091d63          	bnez	s2,8000369c <bmap+0x72>
      addr = balloc(ip->dev);
    80003686:	4108                	lw	a0,0(a0)
    80003688:	00000097          	auipc	ra,0x0
    8000368c:	e70080e7          	jalr	-400(ra) # 800034f8 <balloc>
    80003690:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003694:	02090d63          	beqz	s2,800036ce <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003698:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000369c:	85ca                	mv	a1,s2
    8000369e:	0009a503          	lw	a0,0(s3)
    800036a2:	00000097          	auipc	ra,0x0
    800036a6:	b96080e7          	jalr	-1130(ra) # 80003238 <bread>
    800036aa:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800036ac:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    800036b0:	02049713          	sll	a4,s1,0x20
    800036b4:	01e75593          	srl	a1,a4,0x1e
    800036b8:	00b784b3          	add	s1,a5,a1
    800036bc:	0004a903          	lw	s2,0(s1)
    800036c0:	02090063          	beqz	s2,800036e0 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800036c4:	8552                	mv	a0,s4
    800036c6:	00000097          	auipc	ra,0x0
    800036ca:	ca2080e7          	jalr	-862(ra) # 80003368 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800036ce:	854a                	mv	a0,s2
    800036d0:	70a2                	ld	ra,40(sp)
    800036d2:	7402                	ld	s0,32(sp)
    800036d4:	64e2                	ld	s1,24(sp)
    800036d6:	6942                	ld	s2,16(sp)
    800036d8:	69a2                	ld	s3,8(sp)
    800036da:	6a02                	ld	s4,0(sp)
    800036dc:	6145                	add	sp,sp,48
    800036de:	8082                	ret
      addr = balloc(ip->dev);
    800036e0:	0009a503          	lw	a0,0(s3)
    800036e4:	00000097          	auipc	ra,0x0
    800036e8:	e14080e7          	jalr	-492(ra) # 800034f8 <balloc>
    800036ec:	0005091b          	sext.w	s2,a0
      if(addr){
    800036f0:	fc090ae3          	beqz	s2,800036c4 <bmap+0x9a>
        a[bn] = addr;
    800036f4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800036f8:	8552                	mv	a0,s4
    800036fa:	00001097          	auipc	ra,0x1
    800036fe:	ec6080e7          	jalr	-314(ra) # 800045c0 <log_write>
    80003702:	b7c9                	j	800036c4 <bmap+0x9a>
  panic("bmap: out of range");
    80003704:	00005517          	auipc	a0,0x5
    80003708:	e8450513          	add	a0,a0,-380 # 80008588 <syscalls+0x138>
    8000370c:	ffffd097          	auipc	ra,0xffffd
    80003710:	e30080e7          	jalr	-464(ra) # 8000053c <panic>

0000000080003714 <iget>:
{
    80003714:	7179                	add	sp,sp,-48
    80003716:	f406                	sd	ra,40(sp)
    80003718:	f022                	sd	s0,32(sp)
    8000371a:	ec26                	sd	s1,24(sp)
    8000371c:	e84a                	sd	s2,16(sp)
    8000371e:	e44e                	sd	s3,8(sp)
    80003720:	e052                	sd	s4,0(sp)
    80003722:	1800                	add	s0,sp,48
    80003724:	89aa                	mv	s3,a0
    80003726:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003728:	0001c517          	auipc	a0,0x1c
    8000372c:	58050513          	add	a0,a0,1408 # 8001fca8 <itable>
    80003730:	ffffd097          	auipc	ra,0xffffd
    80003734:	4a2080e7          	jalr	1186(ra) # 80000bd2 <acquire>
  empty = 0;
    80003738:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000373a:	0001c497          	auipc	s1,0x1c
    8000373e:	58648493          	add	s1,s1,1414 # 8001fcc0 <itable+0x18>
    80003742:	0001e697          	auipc	a3,0x1e
    80003746:	00e68693          	add	a3,a3,14 # 80021750 <log>
    8000374a:	a039                	j	80003758 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000374c:	02090b63          	beqz	s2,80003782 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003750:	08848493          	add	s1,s1,136
    80003754:	02d48a63          	beq	s1,a3,80003788 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003758:	449c                	lw	a5,8(s1)
    8000375a:	fef059e3          	blez	a5,8000374c <iget+0x38>
    8000375e:	4098                	lw	a4,0(s1)
    80003760:	ff3716e3          	bne	a4,s3,8000374c <iget+0x38>
    80003764:	40d8                	lw	a4,4(s1)
    80003766:	ff4713e3          	bne	a4,s4,8000374c <iget+0x38>
      ip->ref++;
    8000376a:	2785                	addw	a5,a5,1
    8000376c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000376e:	0001c517          	auipc	a0,0x1c
    80003772:	53a50513          	add	a0,a0,1338 # 8001fca8 <itable>
    80003776:	ffffd097          	auipc	ra,0xffffd
    8000377a:	510080e7          	jalr	1296(ra) # 80000c86 <release>
      return ip;
    8000377e:	8926                	mv	s2,s1
    80003780:	a03d                	j	800037ae <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003782:	f7f9                	bnez	a5,80003750 <iget+0x3c>
    80003784:	8926                	mv	s2,s1
    80003786:	b7e9                	j	80003750 <iget+0x3c>
  if(empty == 0)
    80003788:	02090c63          	beqz	s2,800037c0 <iget+0xac>
  ip->dev = dev;
    8000378c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003790:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003794:	4785                	li	a5,1
    80003796:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000379a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000379e:	0001c517          	auipc	a0,0x1c
    800037a2:	50a50513          	add	a0,a0,1290 # 8001fca8 <itable>
    800037a6:	ffffd097          	auipc	ra,0xffffd
    800037aa:	4e0080e7          	jalr	1248(ra) # 80000c86 <release>
}
    800037ae:	854a                	mv	a0,s2
    800037b0:	70a2                	ld	ra,40(sp)
    800037b2:	7402                	ld	s0,32(sp)
    800037b4:	64e2                	ld	s1,24(sp)
    800037b6:	6942                	ld	s2,16(sp)
    800037b8:	69a2                	ld	s3,8(sp)
    800037ba:	6a02                	ld	s4,0(sp)
    800037bc:	6145                	add	sp,sp,48
    800037be:	8082                	ret
    panic("iget: no inodes");
    800037c0:	00005517          	auipc	a0,0x5
    800037c4:	de050513          	add	a0,a0,-544 # 800085a0 <syscalls+0x150>
    800037c8:	ffffd097          	auipc	ra,0xffffd
    800037cc:	d74080e7          	jalr	-652(ra) # 8000053c <panic>

00000000800037d0 <fsinit>:
fsinit(int dev) {
    800037d0:	7179                	add	sp,sp,-48
    800037d2:	f406                	sd	ra,40(sp)
    800037d4:	f022                	sd	s0,32(sp)
    800037d6:	ec26                	sd	s1,24(sp)
    800037d8:	e84a                	sd	s2,16(sp)
    800037da:	e44e                	sd	s3,8(sp)
    800037dc:	1800                	add	s0,sp,48
    800037de:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800037e0:	4585                	li	a1,1
    800037e2:	00000097          	auipc	ra,0x0
    800037e6:	a56080e7          	jalr	-1450(ra) # 80003238 <bread>
    800037ea:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800037ec:	0001c997          	auipc	s3,0x1c
    800037f0:	49c98993          	add	s3,s3,1180 # 8001fc88 <sb>
    800037f4:	02000613          	li	a2,32
    800037f8:	05850593          	add	a1,a0,88
    800037fc:	854e                	mv	a0,s3
    800037fe:	ffffd097          	auipc	ra,0xffffd
    80003802:	52c080e7          	jalr	1324(ra) # 80000d2a <memmove>
  brelse(bp);
    80003806:	8526                	mv	a0,s1
    80003808:	00000097          	auipc	ra,0x0
    8000380c:	b60080e7          	jalr	-1184(ra) # 80003368 <brelse>
  if(sb.magic != FSMAGIC)
    80003810:	0009a703          	lw	a4,0(s3)
    80003814:	102037b7          	lui	a5,0x10203
    80003818:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000381c:	02f71263          	bne	a4,a5,80003840 <fsinit+0x70>
  initlog(dev, &sb);
    80003820:	0001c597          	auipc	a1,0x1c
    80003824:	46858593          	add	a1,a1,1128 # 8001fc88 <sb>
    80003828:	854a                	mv	a0,s2
    8000382a:	00001097          	auipc	ra,0x1
    8000382e:	b2c080e7          	jalr	-1236(ra) # 80004356 <initlog>
}
    80003832:	70a2                	ld	ra,40(sp)
    80003834:	7402                	ld	s0,32(sp)
    80003836:	64e2                	ld	s1,24(sp)
    80003838:	6942                	ld	s2,16(sp)
    8000383a:	69a2                	ld	s3,8(sp)
    8000383c:	6145                	add	sp,sp,48
    8000383e:	8082                	ret
    panic("invalid file system");
    80003840:	00005517          	auipc	a0,0x5
    80003844:	d7050513          	add	a0,a0,-656 # 800085b0 <syscalls+0x160>
    80003848:	ffffd097          	auipc	ra,0xffffd
    8000384c:	cf4080e7          	jalr	-780(ra) # 8000053c <panic>

0000000080003850 <iinit>:
{
    80003850:	7179                	add	sp,sp,-48
    80003852:	f406                	sd	ra,40(sp)
    80003854:	f022                	sd	s0,32(sp)
    80003856:	ec26                	sd	s1,24(sp)
    80003858:	e84a                	sd	s2,16(sp)
    8000385a:	e44e                	sd	s3,8(sp)
    8000385c:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    8000385e:	00005597          	auipc	a1,0x5
    80003862:	d6a58593          	add	a1,a1,-662 # 800085c8 <syscalls+0x178>
    80003866:	0001c517          	auipc	a0,0x1c
    8000386a:	44250513          	add	a0,a0,1090 # 8001fca8 <itable>
    8000386e:	ffffd097          	auipc	ra,0xffffd
    80003872:	2d4080e7          	jalr	724(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003876:	0001c497          	auipc	s1,0x1c
    8000387a:	45a48493          	add	s1,s1,1114 # 8001fcd0 <itable+0x28>
    8000387e:	0001e997          	auipc	s3,0x1e
    80003882:	ee298993          	add	s3,s3,-286 # 80021760 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003886:	00005917          	auipc	s2,0x5
    8000388a:	d4a90913          	add	s2,s2,-694 # 800085d0 <syscalls+0x180>
    8000388e:	85ca                	mv	a1,s2
    80003890:	8526                	mv	a0,s1
    80003892:	00001097          	auipc	ra,0x1
    80003896:	e12080e7          	jalr	-494(ra) # 800046a4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000389a:	08848493          	add	s1,s1,136
    8000389e:	ff3498e3          	bne	s1,s3,8000388e <iinit+0x3e>
}
    800038a2:	70a2                	ld	ra,40(sp)
    800038a4:	7402                	ld	s0,32(sp)
    800038a6:	64e2                	ld	s1,24(sp)
    800038a8:	6942                	ld	s2,16(sp)
    800038aa:	69a2                	ld	s3,8(sp)
    800038ac:	6145                	add	sp,sp,48
    800038ae:	8082                	ret

00000000800038b0 <ialloc>:
{
    800038b0:	7139                	add	sp,sp,-64
    800038b2:	fc06                	sd	ra,56(sp)
    800038b4:	f822                	sd	s0,48(sp)
    800038b6:	f426                	sd	s1,40(sp)
    800038b8:	f04a                	sd	s2,32(sp)
    800038ba:	ec4e                	sd	s3,24(sp)
    800038bc:	e852                	sd	s4,16(sp)
    800038be:	e456                	sd	s5,8(sp)
    800038c0:	e05a                	sd	s6,0(sp)
    800038c2:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800038c4:	0001c717          	auipc	a4,0x1c
    800038c8:	3d072703          	lw	a4,976(a4) # 8001fc94 <sb+0xc>
    800038cc:	4785                	li	a5,1
    800038ce:	04e7f863          	bgeu	a5,a4,8000391e <ialloc+0x6e>
    800038d2:	8aaa                	mv	s5,a0
    800038d4:	8b2e                	mv	s6,a1
    800038d6:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800038d8:	0001ca17          	auipc	s4,0x1c
    800038dc:	3b0a0a13          	add	s4,s4,944 # 8001fc88 <sb>
    800038e0:	00495593          	srl	a1,s2,0x4
    800038e4:	018a2783          	lw	a5,24(s4)
    800038e8:	9dbd                	addw	a1,a1,a5
    800038ea:	8556                	mv	a0,s5
    800038ec:	00000097          	auipc	ra,0x0
    800038f0:	94c080e7          	jalr	-1716(ra) # 80003238 <bread>
    800038f4:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800038f6:	05850993          	add	s3,a0,88
    800038fa:	00f97793          	and	a5,s2,15
    800038fe:	079a                	sll	a5,a5,0x6
    80003900:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003902:	00099783          	lh	a5,0(s3)
    80003906:	cf9d                	beqz	a5,80003944 <ialloc+0x94>
    brelse(bp);
    80003908:	00000097          	auipc	ra,0x0
    8000390c:	a60080e7          	jalr	-1440(ra) # 80003368 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003910:	0905                	add	s2,s2,1
    80003912:	00ca2703          	lw	a4,12(s4)
    80003916:	0009079b          	sext.w	a5,s2
    8000391a:	fce7e3e3          	bltu	a5,a4,800038e0 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    8000391e:	00005517          	auipc	a0,0x5
    80003922:	cba50513          	add	a0,a0,-838 # 800085d8 <syscalls+0x188>
    80003926:	ffffd097          	auipc	ra,0xffffd
    8000392a:	c60080e7          	jalr	-928(ra) # 80000586 <printf>
  return 0;
    8000392e:	4501                	li	a0,0
}
    80003930:	70e2                	ld	ra,56(sp)
    80003932:	7442                	ld	s0,48(sp)
    80003934:	74a2                	ld	s1,40(sp)
    80003936:	7902                	ld	s2,32(sp)
    80003938:	69e2                	ld	s3,24(sp)
    8000393a:	6a42                	ld	s4,16(sp)
    8000393c:	6aa2                	ld	s5,8(sp)
    8000393e:	6b02                	ld	s6,0(sp)
    80003940:	6121                	add	sp,sp,64
    80003942:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003944:	04000613          	li	a2,64
    80003948:	4581                	li	a1,0
    8000394a:	854e                	mv	a0,s3
    8000394c:	ffffd097          	auipc	ra,0xffffd
    80003950:	382080e7          	jalr	898(ra) # 80000cce <memset>
      dip->type = type;
    80003954:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003958:	8526                	mv	a0,s1
    8000395a:	00001097          	auipc	ra,0x1
    8000395e:	c66080e7          	jalr	-922(ra) # 800045c0 <log_write>
      brelse(bp);
    80003962:	8526                	mv	a0,s1
    80003964:	00000097          	auipc	ra,0x0
    80003968:	a04080e7          	jalr	-1532(ra) # 80003368 <brelse>
      return iget(dev, inum);
    8000396c:	0009059b          	sext.w	a1,s2
    80003970:	8556                	mv	a0,s5
    80003972:	00000097          	auipc	ra,0x0
    80003976:	da2080e7          	jalr	-606(ra) # 80003714 <iget>
    8000397a:	bf5d                	j	80003930 <ialloc+0x80>

000000008000397c <iupdate>:
{
    8000397c:	1101                	add	sp,sp,-32
    8000397e:	ec06                	sd	ra,24(sp)
    80003980:	e822                	sd	s0,16(sp)
    80003982:	e426                	sd	s1,8(sp)
    80003984:	e04a                	sd	s2,0(sp)
    80003986:	1000                	add	s0,sp,32
    80003988:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000398a:	415c                	lw	a5,4(a0)
    8000398c:	0047d79b          	srlw	a5,a5,0x4
    80003990:	0001c597          	auipc	a1,0x1c
    80003994:	3105a583          	lw	a1,784(a1) # 8001fca0 <sb+0x18>
    80003998:	9dbd                	addw	a1,a1,a5
    8000399a:	4108                	lw	a0,0(a0)
    8000399c:	00000097          	auipc	ra,0x0
    800039a0:	89c080e7          	jalr	-1892(ra) # 80003238 <bread>
    800039a4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039a6:	05850793          	add	a5,a0,88
    800039aa:	40d8                	lw	a4,4(s1)
    800039ac:	8b3d                	and	a4,a4,15
    800039ae:	071a                	sll	a4,a4,0x6
    800039b0:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800039b2:	04449703          	lh	a4,68(s1)
    800039b6:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800039ba:	04649703          	lh	a4,70(s1)
    800039be:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800039c2:	04849703          	lh	a4,72(s1)
    800039c6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800039ca:	04a49703          	lh	a4,74(s1)
    800039ce:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800039d2:	44f8                	lw	a4,76(s1)
    800039d4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800039d6:	03400613          	li	a2,52
    800039da:	05048593          	add	a1,s1,80
    800039de:	00c78513          	add	a0,a5,12
    800039e2:	ffffd097          	auipc	ra,0xffffd
    800039e6:	348080e7          	jalr	840(ra) # 80000d2a <memmove>
  log_write(bp);
    800039ea:	854a                	mv	a0,s2
    800039ec:	00001097          	auipc	ra,0x1
    800039f0:	bd4080e7          	jalr	-1068(ra) # 800045c0 <log_write>
  brelse(bp);
    800039f4:	854a                	mv	a0,s2
    800039f6:	00000097          	auipc	ra,0x0
    800039fa:	972080e7          	jalr	-1678(ra) # 80003368 <brelse>
}
    800039fe:	60e2                	ld	ra,24(sp)
    80003a00:	6442                	ld	s0,16(sp)
    80003a02:	64a2                	ld	s1,8(sp)
    80003a04:	6902                	ld	s2,0(sp)
    80003a06:	6105                	add	sp,sp,32
    80003a08:	8082                	ret

0000000080003a0a <idup>:
{
    80003a0a:	1101                	add	sp,sp,-32
    80003a0c:	ec06                	sd	ra,24(sp)
    80003a0e:	e822                	sd	s0,16(sp)
    80003a10:	e426                	sd	s1,8(sp)
    80003a12:	1000                	add	s0,sp,32
    80003a14:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a16:	0001c517          	auipc	a0,0x1c
    80003a1a:	29250513          	add	a0,a0,658 # 8001fca8 <itable>
    80003a1e:	ffffd097          	auipc	ra,0xffffd
    80003a22:	1b4080e7          	jalr	436(ra) # 80000bd2 <acquire>
  ip->ref++;
    80003a26:	449c                	lw	a5,8(s1)
    80003a28:	2785                	addw	a5,a5,1
    80003a2a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a2c:	0001c517          	auipc	a0,0x1c
    80003a30:	27c50513          	add	a0,a0,636 # 8001fca8 <itable>
    80003a34:	ffffd097          	auipc	ra,0xffffd
    80003a38:	252080e7          	jalr	594(ra) # 80000c86 <release>
}
    80003a3c:	8526                	mv	a0,s1
    80003a3e:	60e2                	ld	ra,24(sp)
    80003a40:	6442                	ld	s0,16(sp)
    80003a42:	64a2                	ld	s1,8(sp)
    80003a44:	6105                	add	sp,sp,32
    80003a46:	8082                	ret

0000000080003a48 <ilock>:
{
    80003a48:	1101                	add	sp,sp,-32
    80003a4a:	ec06                	sd	ra,24(sp)
    80003a4c:	e822                	sd	s0,16(sp)
    80003a4e:	e426                	sd	s1,8(sp)
    80003a50:	e04a                	sd	s2,0(sp)
    80003a52:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003a54:	c115                	beqz	a0,80003a78 <ilock+0x30>
    80003a56:	84aa                	mv	s1,a0
    80003a58:	451c                	lw	a5,8(a0)
    80003a5a:	00f05f63          	blez	a5,80003a78 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003a5e:	0541                	add	a0,a0,16
    80003a60:	00001097          	auipc	ra,0x1
    80003a64:	c7e080e7          	jalr	-898(ra) # 800046de <acquiresleep>
  if(ip->valid == 0){
    80003a68:	40bc                	lw	a5,64(s1)
    80003a6a:	cf99                	beqz	a5,80003a88 <ilock+0x40>
}
    80003a6c:	60e2                	ld	ra,24(sp)
    80003a6e:	6442                	ld	s0,16(sp)
    80003a70:	64a2                	ld	s1,8(sp)
    80003a72:	6902                	ld	s2,0(sp)
    80003a74:	6105                	add	sp,sp,32
    80003a76:	8082                	ret
    panic("ilock");
    80003a78:	00005517          	auipc	a0,0x5
    80003a7c:	b7850513          	add	a0,a0,-1160 # 800085f0 <syscalls+0x1a0>
    80003a80:	ffffd097          	auipc	ra,0xffffd
    80003a84:	abc080e7          	jalr	-1348(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a88:	40dc                	lw	a5,4(s1)
    80003a8a:	0047d79b          	srlw	a5,a5,0x4
    80003a8e:	0001c597          	auipc	a1,0x1c
    80003a92:	2125a583          	lw	a1,530(a1) # 8001fca0 <sb+0x18>
    80003a96:	9dbd                	addw	a1,a1,a5
    80003a98:	4088                	lw	a0,0(s1)
    80003a9a:	fffff097          	auipc	ra,0xfffff
    80003a9e:	79e080e7          	jalr	1950(ra) # 80003238 <bread>
    80003aa2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003aa4:	05850593          	add	a1,a0,88
    80003aa8:	40dc                	lw	a5,4(s1)
    80003aaa:	8bbd                	and	a5,a5,15
    80003aac:	079a                	sll	a5,a5,0x6
    80003aae:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003ab0:	00059783          	lh	a5,0(a1)
    80003ab4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003ab8:	00259783          	lh	a5,2(a1)
    80003abc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003ac0:	00459783          	lh	a5,4(a1)
    80003ac4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003ac8:	00659783          	lh	a5,6(a1)
    80003acc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003ad0:	459c                	lw	a5,8(a1)
    80003ad2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003ad4:	03400613          	li	a2,52
    80003ad8:	05b1                	add	a1,a1,12
    80003ada:	05048513          	add	a0,s1,80
    80003ade:	ffffd097          	auipc	ra,0xffffd
    80003ae2:	24c080e7          	jalr	588(ra) # 80000d2a <memmove>
    brelse(bp);
    80003ae6:	854a                	mv	a0,s2
    80003ae8:	00000097          	auipc	ra,0x0
    80003aec:	880080e7          	jalr	-1920(ra) # 80003368 <brelse>
    ip->valid = 1;
    80003af0:	4785                	li	a5,1
    80003af2:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003af4:	04449783          	lh	a5,68(s1)
    80003af8:	fbb5                	bnez	a5,80003a6c <ilock+0x24>
      panic("ilock: no type");
    80003afa:	00005517          	auipc	a0,0x5
    80003afe:	afe50513          	add	a0,a0,-1282 # 800085f8 <syscalls+0x1a8>
    80003b02:	ffffd097          	auipc	ra,0xffffd
    80003b06:	a3a080e7          	jalr	-1478(ra) # 8000053c <panic>

0000000080003b0a <iunlock>:
{
    80003b0a:	1101                	add	sp,sp,-32
    80003b0c:	ec06                	sd	ra,24(sp)
    80003b0e:	e822                	sd	s0,16(sp)
    80003b10:	e426                	sd	s1,8(sp)
    80003b12:	e04a                	sd	s2,0(sp)
    80003b14:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003b16:	c905                	beqz	a0,80003b46 <iunlock+0x3c>
    80003b18:	84aa                	mv	s1,a0
    80003b1a:	01050913          	add	s2,a0,16
    80003b1e:	854a                	mv	a0,s2
    80003b20:	00001097          	auipc	ra,0x1
    80003b24:	c58080e7          	jalr	-936(ra) # 80004778 <holdingsleep>
    80003b28:	cd19                	beqz	a0,80003b46 <iunlock+0x3c>
    80003b2a:	449c                	lw	a5,8(s1)
    80003b2c:	00f05d63          	blez	a5,80003b46 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003b30:	854a                	mv	a0,s2
    80003b32:	00001097          	auipc	ra,0x1
    80003b36:	c02080e7          	jalr	-1022(ra) # 80004734 <releasesleep>
}
    80003b3a:	60e2                	ld	ra,24(sp)
    80003b3c:	6442                	ld	s0,16(sp)
    80003b3e:	64a2                	ld	s1,8(sp)
    80003b40:	6902                	ld	s2,0(sp)
    80003b42:	6105                	add	sp,sp,32
    80003b44:	8082                	ret
    panic("iunlock");
    80003b46:	00005517          	auipc	a0,0x5
    80003b4a:	ac250513          	add	a0,a0,-1342 # 80008608 <syscalls+0x1b8>
    80003b4e:	ffffd097          	auipc	ra,0xffffd
    80003b52:	9ee080e7          	jalr	-1554(ra) # 8000053c <panic>

0000000080003b56 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003b56:	7179                	add	sp,sp,-48
    80003b58:	f406                	sd	ra,40(sp)
    80003b5a:	f022                	sd	s0,32(sp)
    80003b5c:	ec26                	sd	s1,24(sp)
    80003b5e:	e84a                	sd	s2,16(sp)
    80003b60:	e44e                	sd	s3,8(sp)
    80003b62:	e052                	sd	s4,0(sp)
    80003b64:	1800                	add	s0,sp,48
    80003b66:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b68:	05050493          	add	s1,a0,80
    80003b6c:	08050913          	add	s2,a0,128
    80003b70:	a021                	j	80003b78 <itrunc+0x22>
    80003b72:	0491                	add	s1,s1,4
    80003b74:	01248d63          	beq	s1,s2,80003b8e <itrunc+0x38>
    if(ip->addrs[i]){
    80003b78:	408c                	lw	a1,0(s1)
    80003b7a:	dde5                	beqz	a1,80003b72 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003b7c:	0009a503          	lw	a0,0(s3)
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	8fc080e7          	jalr	-1796(ra) # 8000347c <bfree>
      ip->addrs[i] = 0;
    80003b88:	0004a023          	sw	zero,0(s1)
    80003b8c:	b7dd                	j	80003b72 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b8e:	0809a583          	lw	a1,128(s3)
    80003b92:	e185                	bnez	a1,80003bb2 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b94:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b98:	854e                	mv	a0,s3
    80003b9a:	00000097          	auipc	ra,0x0
    80003b9e:	de2080e7          	jalr	-542(ra) # 8000397c <iupdate>
}
    80003ba2:	70a2                	ld	ra,40(sp)
    80003ba4:	7402                	ld	s0,32(sp)
    80003ba6:	64e2                	ld	s1,24(sp)
    80003ba8:	6942                	ld	s2,16(sp)
    80003baa:	69a2                	ld	s3,8(sp)
    80003bac:	6a02                	ld	s4,0(sp)
    80003bae:	6145                	add	sp,sp,48
    80003bb0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003bb2:	0009a503          	lw	a0,0(s3)
    80003bb6:	fffff097          	auipc	ra,0xfffff
    80003bba:	682080e7          	jalr	1666(ra) # 80003238 <bread>
    80003bbe:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003bc0:	05850493          	add	s1,a0,88
    80003bc4:	45850913          	add	s2,a0,1112
    80003bc8:	a021                	j	80003bd0 <itrunc+0x7a>
    80003bca:	0491                	add	s1,s1,4
    80003bcc:	01248b63          	beq	s1,s2,80003be2 <itrunc+0x8c>
      if(a[j])
    80003bd0:	408c                	lw	a1,0(s1)
    80003bd2:	dde5                	beqz	a1,80003bca <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003bd4:	0009a503          	lw	a0,0(s3)
    80003bd8:	00000097          	auipc	ra,0x0
    80003bdc:	8a4080e7          	jalr	-1884(ra) # 8000347c <bfree>
    80003be0:	b7ed                	j	80003bca <itrunc+0x74>
    brelse(bp);
    80003be2:	8552                	mv	a0,s4
    80003be4:	fffff097          	auipc	ra,0xfffff
    80003be8:	784080e7          	jalr	1924(ra) # 80003368 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003bec:	0809a583          	lw	a1,128(s3)
    80003bf0:	0009a503          	lw	a0,0(s3)
    80003bf4:	00000097          	auipc	ra,0x0
    80003bf8:	888080e7          	jalr	-1912(ra) # 8000347c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003bfc:	0809a023          	sw	zero,128(s3)
    80003c00:	bf51                	j	80003b94 <itrunc+0x3e>

0000000080003c02 <iput>:
{
    80003c02:	1101                	add	sp,sp,-32
    80003c04:	ec06                	sd	ra,24(sp)
    80003c06:	e822                	sd	s0,16(sp)
    80003c08:	e426                	sd	s1,8(sp)
    80003c0a:	e04a                	sd	s2,0(sp)
    80003c0c:	1000                	add	s0,sp,32
    80003c0e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c10:	0001c517          	auipc	a0,0x1c
    80003c14:	09850513          	add	a0,a0,152 # 8001fca8 <itable>
    80003c18:	ffffd097          	auipc	ra,0xffffd
    80003c1c:	fba080e7          	jalr	-70(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c20:	4498                	lw	a4,8(s1)
    80003c22:	4785                	li	a5,1
    80003c24:	02f70363          	beq	a4,a5,80003c4a <iput+0x48>
  ip->ref--;
    80003c28:	449c                	lw	a5,8(s1)
    80003c2a:	37fd                	addw	a5,a5,-1
    80003c2c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c2e:	0001c517          	auipc	a0,0x1c
    80003c32:	07a50513          	add	a0,a0,122 # 8001fca8 <itable>
    80003c36:	ffffd097          	auipc	ra,0xffffd
    80003c3a:	050080e7          	jalr	80(ra) # 80000c86 <release>
}
    80003c3e:	60e2                	ld	ra,24(sp)
    80003c40:	6442                	ld	s0,16(sp)
    80003c42:	64a2                	ld	s1,8(sp)
    80003c44:	6902                	ld	s2,0(sp)
    80003c46:	6105                	add	sp,sp,32
    80003c48:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c4a:	40bc                	lw	a5,64(s1)
    80003c4c:	dff1                	beqz	a5,80003c28 <iput+0x26>
    80003c4e:	04a49783          	lh	a5,74(s1)
    80003c52:	fbf9                	bnez	a5,80003c28 <iput+0x26>
    acquiresleep(&ip->lock);
    80003c54:	01048913          	add	s2,s1,16
    80003c58:	854a                	mv	a0,s2
    80003c5a:	00001097          	auipc	ra,0x1
    80003c5e:	a84080e7          	jalr	-1404(ra) # 800046de <acquiresleep>
    release(&itable.lock);
    80003c62:	0001c517          	auipc	a0,0x1c
    80003c66:	04650513          	add	a0,a0,70 # 8001fca8 <itable>
    80003c6a:	ffffd097          	auipc	ra,0xffffd
    80003c6e:	01c080e7          	jalr	28(ra) # 80000c86 <release>
    itrunc(ip);
    80003c72:	8526                	mv	a0,s1
    80003c74:	00000097          	auipc	ra,0x0
    80003c78:	ee2080e7          	jalr	-286(ra) # 80003b56 <itrunc>
    ip->type = 0;
    80003c7c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c80:	8526                	mv	a0,s1
    80003c82:	00000097          	auipc	ra,0x0
    80003c86:	cfa080e7          	jalr	-774(ra) # 8000397c <iupdate>
    ip->valid = 0;
    80003c8a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c8e:	854a                	mv	a0,s2
    80003c90:	00001097          	auipc	ra,0x1
    80003c94:	aa4080e7          	jalr	-1372(ra) # 80004734 <releasesleep>
    acquire(&itable.lock);
    80003c98:	0001c517          	auipc	a0,0x1c
    80003c9c:	01050513          	add	a0,a0,16 # 8001fca8 <itable>
    80003ca0:	ffffd097          	auipc	ra,0xffffd
    80003ca4:	f32080e7          	jalr	-206(ra) # 80000bd2 <acquire>
    80003ca8:	b741                	j	80003c28 <iput+0x26>

0000000080003caa <iunlockput>:
{
    80003caa:	1101                	add	sp,sp,-32
    80003cac:	ec06                	sd	ra,24(sp)
    80003cae:	e822                	sd	s0,16(sp)
    80003cb0:	e426                	sd	s1,8(sp)
    80003cb2:	1000                	add	s0,sp,32
    80003cb4:	84aa                	mv	s1,a0
  iunlock(ip);
    80003cb6:	00000097          	auipc	ra,0x0
    80003cba:	e54080e7          	jalr	-428(ra) # 80003b0a <iunlock>
  iput(ip);
    80003cbe:	8526                	mv	a0,s1
    80003cc0:	00000097          	auipc	ra,0x0
    80003cc4:	f42080e7          	jalr	-190(ra) # 80003c02 <iput>
}
    80003cc8:	60e2                	ld	ra,24(sp)
    80003cca:	6442                	ld	s0,16(sp)
    80003ccc:	64a2                	ld	s1,8(sp)
    80003cce:	6105                	add	sp,sp,32
    80003cd0:	8082                	ret

0000000080003cd2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003cd2:	1141                	add	sp,sp,-16
    80003cd4:	e422                	sd	s0,8(sp)
    80003cd6:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003cd8:	411c                	lw	a5,0(a0)
    80003cda:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003cdc:	415c                	lw	a5,4(a0)
    80003cde:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003ce0:	04451783          	lh	a5,68(a0)
    80003ce4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003ce8:	04a51783          	lh	a5,74(a0)
    80003cec:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003cf0:	04c56783          	lwu	a5,76(a0)
    80003cf4:	e99c                	sd	a5,16(a1)
}
    80003cf6:	6422                	ld	s0,8(sp)
    80003cf8:	0141                	add	sp,sp,16
    80003cfa:	8082                	ret

0000000080003cfc <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cfc:	457c                	lw	a5,76(a0)
    80003cfe:	0ed7e963          	bltu	a5,a3,80003df0 <readi+0xf4>
{
    80003d02:	7159                	add	sp,sp,-112
    80003d04:	f486                	sd	ra,104(sp)
    80003d06:	f0a2                	sd	s0,96(sp)
    80003d08:	eca6                	sd	s1,88(sp)
    80003d0a:	e8ca                	sd	s2,80(sp)
    80003d0c:	e4ce                	sd	s3,72(sp)
    80003d0e:	e0d2                	sd	s4,64(sp)
    80003d10:	fc56                	sd	s5,56(sp)
    80003d12:	f85a                	sd	s6,48(sp)
    80003d14:	f45e                	sd	s7,40(sp)
    80003d16:	f062                	sd	s8,32(sp)
    80003d18:	ec66                	sd	s9,24(sp)
    80003d1a:	e86a                	sd	s10,16(sp)
    80003d1c:	e46e                	sd	s11,8(sp)
    80003d1e:	1880                	add	s0,sp,112
    80003d20:	8b2a                	mv	s6,a0
    80003d22:	8bae                	mv	s7,a1
    80003d24:	8a32                	mv	s4,a2
    80003d26:	84b6                	mv	s1,a3
    80003d28:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003d2a:	9f35                	addw	a4,a4,a3
    return 0;
    80003d2c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003d2e:	0ad76063          	bltu	a4,a3,80003dce <readi+0xd2>
  if(off + n > ip->size)
    80003d32:	00e7f463          	bgeu	a5,a4,80003d3a <readi+0x3e>
    n = ip->size - off;
    80003d36:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d3a:	0a0a8963          	beqz	s5,80003dec <readi+0xf0>
    80003d3e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d40:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003d44:	5c7d                	li	s8,-1
    80003d46:	a82d                	j	80003d80 <readi+0x84>
    80003d48:	020d1d93          	sll	s11,s10,0x20
    80003d4c:	020ddd93          	srl	s11,s11,0x20
    80003d50:	05890613          	add	a2,s2,88
    80003d54:	86ee                	mv	a3,s11
    80003d56:	963a                	add	a2,a2,a4
    80003d58:	85d2                	mv	a1,s4
    80003d5a:	855e                	mv	a0,s7
    80003d5c:	ffffe097          	auipc	ra,0xffffe
    80003d60:	7ac080e7          	jalr	1964(ra) # 80002508 <either_copyout>
    80003d64:	05850d63          	beq	a0,s8,80003dbe <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003d68:	854a                	mv	a0,s2
    80003d6a:	fffff097          	auipc	ra,0xfffff
    80003d6e:	5fe080e7          	jalr	1534(ra) # 80003368 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d72:	013d09bb          	addw	s3,s10,s3
    80003d76:	009d04bb          	addw	s1,s10,s1
    80003d7a:	9a6e                	add	s4,s4,s11
    80003d7c:	0559f763          	bgeu	s3,s5,80003dca <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003d80:	00a4d59b          	srlw	a1,s1,0xa
    80003d84:	855a                	mv	a0,s6
    80003d86:	00000097          	auipc	ra,0x0
    80003d8a:	8a4080e7          	jalr	-1884(ra) # 8000362a <bmap>
    80003d8e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d92:	cd85                	beqz	a1,80003dca <readi+0xce>
    bp = bread(ip->dev, addr);
    80003d94:	000b2503          	lw	a0,0(s6)
    80003d98:	fffff097          	auipc	ra,0xfffff
    80003d9c:	4a0080e7          	jalr	1184(ra) # 80003238 <bread>
    80003da0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003da2:	3ff4f713          	and	a4,s1,1023
    80003da6:	40ec87bb          	subw	a5,s9,a4
    80003daa:	413a86bb          	subw	a3,s5,s3
    80003dae:	8d3e                	mv	s10,a5
    80003db0:	2781                	sext.w	a5,a5
    80003db2:	0006861b          	sext.w	a2,a3
    80003db6:	f8f679e3          	bgeu	a2,a5,80003d48 <readi+0x4c>
    80003dba:	8d36                	mv	s10,a3
    80003dbc:	b771                	j	80003d48 <readi+0x4c>
      brelse(bp);
    80003dbe:	854a                	mv	a0,s2
    80003dc0:	fffff097          	auipc	ra,0xfffff
    80003dc4:	5a8080e7          	jalr	1448(ra) # 80003368 <brelse>
      tot = -1;
    80003dc8:	59fd                	li	s3,-1
  }
  return tot;
    80003dca:	0009851b          	sext.w	a0,s3
}
    80003dce:	70a6                	ld	ra,104(sp)
    80003dd0:	7406                	ld	s0,96(sp)
    80003dd2:	64e6                	ld	s1,88(sp)
    80003dd4:	6946                	ld	s2,80(sp)
    80003dd6:	69a6                	ld	s3,72(sp)
    80003dd8:	6a06                	ld	s4,64(sp)
    80003dda:	7ae2                	ld	s5,56(sp)
    80003ddc:	7b42                	ld	s6,48(sp)
    80003dde:	7ba2                	ld	s7,40(sp)
    80003de0:	7c02                	ld	s8,32(sp)
    80003de2:	6ce2                	ld	s9,24(sp)
    80003de4:	6d42                	ld	s10,16(sp)
    80003de6:	6da2                	ld	s11,8(sp)
    80003de8:	6165                	add	sp,sp,112
    80003dea:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dec:	89d6                	mv	s3,s5
    80003dee:	bff1                	j	80003dca <readi+0xce>
    return 0;
    80003df0:	4501                	li	a0,0
}
    80003df2:	8082                	ret

0000000080003df4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003df4:	457c                	lw	a5,76(a0)
    80003df6:	10d7e863          	bltu	a5,a3,80003f06 <writei+0x112>
{
    80003dfa:	7159                	add	sp,sp,-112
    80003dfc:	f486                	sd	ra,104(sp)
    80003dfe:	f0a2                	sd	s0,96(sp)
    80003e00:	eca6                	sd	s1,88(sp)
    80003e02:	e8ca                	sd	s2,80(sp)
    80003e04:	e4ce                	sd	s3,72(sp)
    80003e06:	e0d2                	sd	s4,64(sp)
    80003e08:	fc56                	sd	s5,56(sp)
    80003e0a:	f85a                	sd	s6,48(sp)
    80003e0c:	f45e                	sd	s7,40(sp)
    80003e0e:	f062                	sd	s8,32(sp)
    80003e10:	ec66                	sd	s9,24(sp)
    80003e12:	e86a                	sd	s10,16(sp)
    80003e14:	e46e                	sd	s11,8(sp)
    80003e16:	1880                	add	s0,sp,112
    80003e18:	8aaa                	mv	s5,a0
    80003e1a:	8bae                	mv	s7,a1
    80003e1c:	8a32                	mv	s4,a2
    80003e1e:	8936                	mv	s2,a3
    80003e20:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003e22:	00e687bb          	addw	a5,a3,a4
    80003e26:	0ed7e263          	bltu	a5,a3,80003f0a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003e2a:	00043737          	lui	a4,0x43
    80003e2e:	0ef76063          	bltu	a4,a5,80003f0e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e32:	0c0b0863          	beqz	s6,80003f02 <writei+0x10e>
    80003e36:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e38:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003e3c:	5c7d                	li	s8,-1
    80003e3e:	a091                	j	80003e82 <writei+0x8e>
    80003e40:	020d1d93          	sll	s11,s10,0x20
    80003e44:	020ddd93          	srl	s11,s11,0x20
    80003e48:	05848513          	add	a0,s1,88
    80003e4c:	86ee                	mv	a3,s11
    80003e4e:	8652                	mv	a2,s4
    80003e50:	85de                	mv	a1,s7
    80003e52:	953a                	add	a0,a0,a4
    80003e54:	ffffe097          	auipc	ra,0xffffe
    80003e58:	70a080e7          	jalr	1802(ra) # 8000255e <either_copyin>
    80003e5c:	07850263          	beq	a0,s8,80003ec0 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003e60:	8526                	mv	a0,s1
    80003e62:	00000097          	auipc	ra,0x0
    80003e66:	75e080e7          	jalr	1886(ra) # 800045c0 <log_write>
    brelse(bp);
    80003e6a:	8526                	mv	a0,s1
    80003e6c:	fffff097          	auipc	ra,0xfffff
    80003e70:	4fc080e7          	jalr	1276(ra) # 80003368 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e74:	013d09bb          	addw	s3,s10,s3
    80003e78:	012d093b          	addw	s2,s10,s2
    80003e7c:	9a6e                	add	s4,s4,s11
    80003e7e:	0569f663          	bgeu	s3,s6,80003eca <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003e82:	00a9559b          	srlw	a1,s2,0xa
    80003e86:	8556                	mv	a0,s5
    80003e88:	fffff097          	auipc	ra,0xfffff
    80003e8c:	7a2080e7          	jalr	1954(ra) # 8000362a <bmap>
    80003e90:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e94:	c99d                	beqz	a1,80003eca <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003e96:	000aa503          	lw	a0,0(s5)
    80003e9a:	fffff097          	auipc	ra,0xfffff
    80003e9e:	39e080e7          	jalr	926(ra) # 80003238 <bread>
    80003ea2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ea4:	3ff97713          	and	a4,s2,1023
    80003ea8:	40ec87bb          	subw	a5,s9,a4
    80003eac:	413b06bb          	subw	a3,s6,s3
    80003eb0:	8d3e                	mv	s10,a5
    80003eb2:	2781                	sext.w	a5,a5
    80003eb4:	0006861b          	sext.w	a2,a3
    80003eb8:	f8f674e3          	bgeu	a2,a5,80003e40 <writei+0x4c>
    80003ebc:	8d36                	mv	s10,a3
    80003ebe:	b749                	j	80003e40 <writei+0x4c>
      brelse(bp);
    80003ec0:	8526                	mv	a0,s1
    80003ec2:	fffff097          	auipc	ra,0xfffff
    80003ec6:	4a6080e7          	jalr	1190(ra) # 80003368 <brelse>
  }

  if(off > ip->size)
    80003eca:	04caa783          	lw	a5,76(s5)
    80003ece:	0127f463          	bgeu	a5,s2,80003ed6 <writei+0xe2>
    ip->size = off;
    80003ed2:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ed6:	8556                	mv	a0,s5
    80003ed8:	00000097          	auipc	ra,0x0
    80003edc:	aa4080e7          	jalr	-1372(ra) # 8000397c <iupdate>

  return tot;
    80003ee0:	0009851b          	sext.w	a0,s3
}
    80003ee4:	70a6                	ld	ra,104(sp)
    80003ee6:	7406                	ld	s0,96(sp)
    80003ee8:	64e6                	ld	s1,88(sp)
    80003eea:	6946                	ld	s2,80(sp)
    80003eec:	69a6                	ld	s3,72(sp)
    80003eee:	6a06                	ld	s4,64(sp)
    80003ef0:	7ae2                	ld	s5,56(sp)
    80003ef2:	7b42                	ld	s6,48(sp)
    80003ef4:	7ba2                	ld	s7,40(sp)
    80003ef6:	7c02                	ld	s8,32(sp)
    80003ef8:	6ce2                	ld	s9,24(sp)
    80003efa:	6d42                	ld	s10,16(sp)
    80003efc:	6da2                	ld	s11,8(sp)
    80003efe:	6165                	add	sp,sp,112
    80003f00:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f02:	89da                	mv	s3,s6
    80003f04:	bfc9                	j	80003ed6 <writei+0xe2>
    return -1;
    80003f06:	557d                	li	a0,-1
}
    80003f08:	8082                	ret
    return -1;
    80003f0a:	557d                	li	a0,-1
    80003f0c:	bfe1                	j	80003ee4 <writei+0xf0>
    return -1;
    80003f0e:	557d                	li	a0,-1
    80003f10:	bfd1                	j	80003ee4 <writei+0xf0>

0000000080003f12 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f12:	1141                	add	sp,sp,-16
    80003f14:	e406                	sd	ra,8(sp)
    80003f16:	e022                	sd	s0,0(sp)
    80003f18:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003f1a:	4639                	li	a2,14
    80003f1c:	ffffd097          	auipc	ra,0xffffd
    80003f20:	e82080e7          	jalr	-382(ra) # 80000d9e <strncmp>
}
    80003f24:	60a2                	ld	ra,8(sp)
    80003f26:	6402                	ld	s0,0(sp)
    80003f28:	0141                	add	sp,sp,16
    80003f2a:	8082                	ret

0000000080003f2c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003f2c:	7139                	add	sp,sp,-64
    80003f2e:	fc06                	sd	ra,56(sp)
    80003f30:	f822                	sd	s0,48(sp)
    80003f32:	f426                	sd	s1,40(sp)
    80003f34:	f04a                	sd	s2,32(sp)
    80003f36:	ec4e                	sd	s3,24(sp)
    80003f38:	e852                	sd	s4,16(sp)
    80003f3a:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003f3c:	04451703          	lh	a4,68(a0)
    80003f40:	4785                	li	a5,1
    80003f42:	00f71a63          	bne	a4,a5,80003f56 <dirlookup+0x2a>
    80003f46:	892a                	mv	s2,a0
    80003f48:	89ae                	mv	s3,a1
    80003f4a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f4c:	457c                	lw	a5,76(a0)
    80003f4e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003f50:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f52:	e79d                	bnez	a5,80003f80 <dirlookup+0x54>
    80003f54:	a8a5                	j	80003fcc <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003f56:	00004517          	auipc	a0,0x4
    80003f5a:	6ba50513          	add	a0,a0,1722 # 80008610 <syscalls+0x1c0>
    80003f5e:	ffffc097          	auipc	ra,0xffffc
    80003f62:	5de080e7          	jalr	1502(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003f66:	00004517          	auipc	a0,0x4
    80003f6a:	6c250513          	add	a0,a0,1730 # 80008628 <syscalls+0x1d8>
    80003f6e:	ffffc097          	auipc	ra,0xffffc
    80003f72:	5ce080e7          	jalr	1486(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f76:	24c1                	addw	s1,s1,16
    80003f78:	04c92783          	lw	a5,76(s2)
    80003f7c:	04f4f763          	bgeu	s1,a5,80003fca <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f80:	4741                	li	a4,16
    80003f82:	86a6                	mv	a3,s1
    80003f84:	fc040613          	add	a2,s0,-64
    80003f88:	4581                	li	a1,0
    80003f8a:	854a                	mv	a0,s2
    80003f8c:	00000097          	auipc	ra,0x0
    80003f90:	d70080e7          	jalr	-656(ra) # 80003cfc <readi>
    80003f94:	47c1                	li	a5,16
    80003f96:	fcf518e3          	bne	a0,a5,80003f66 <dirlookup+0x3a>
    if(de.inum == 0)
    80003f9a:	fc045783          	lhu	a5,-64(s0)
    80003f9e:	dfe1                	beqz	a5,80003f76 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003fa0:	fc240593          	add	a1,s0,-62
    80003fa4:	854e                	mv	a0,s3
    80003fa6:	00000097          	auipc	ra,0x0
    80003faa:	f6c080e7          	jalr	-148(ra) # 80003f12 <namecmp>
    80003fae:	f561                	bnez	a0,80003f76 <dirlookup+0x4a>
      if(poff)
    80003fb0:	000a0463          	beqz	s4,80003fb8 <dirlookup+0x8c>
        *poff = off;
    80003fb4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003fb8:	fc045583          	lhu	a1,-64(s0)
    80003fbc:	00092503          	lw	a0,0(s2)
    80003fc0:	fffff097          	auipc	ra,0xfffff
    80003fc4:	754080e7          	jalr	1876(ra) # 80003714 <iget>
    80003fc8:	a011                	j	80003fcc <dirlookup+0xa0>
  return 0;
    80003fca:	4501                	li	a0,0
}
    80003fcc:	70e2                	ld	ra,56(sp)
    80003fce:	7442                	ld	s0,48(sp)
    80003fd0:	74a2                	ld	s1,40(sp)
    80003fd2:	7902                	ld	s2,32(sp)
    80003fd4:	69e2                	ld	s3,24(sp)
    80003fd6:	6a42                	ld	s4,16(sp)
    80003fd8:	6121                	add	sp,sp,64
    80003fda:	8082                	ret

0000000080003fdc <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003fdc:	711d                	add	sp,sp,-96
    80003fde:	ec86                	sd	ra,88(sp)
    80003fe0:	e8a2                	sd	s0,80(sp)
    80003fe2:	e4a6                	sd	s1,72(sp)
    80003fe4:	e0ca                	sd	s2,64(sp)
    80003fe6:	fc4e                	sd	s3,56(sp)
    80003fe8:	f852                	sd	s4,48(sp)
    80003fea:	f456                	sd	s5,40(sp)
    80003fec:	f05a                	sd	s6,32(sp)
    80003fee:	ec5e                	sd	s7,24(sp)
    80003ff0:	e862                	sd	s8,16(sp)
    80003ff2:	e466                	sd	s9,8(sp)
    80003ff4:	1080                	add	s0,sp,96
    80003ff6:	84aa                	mv	s1,a0
    80003ff8:	8b2e                	mv	s6,a1
    80003ffa:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ffc:	00054703          	lbu	a4,0(a0)
    80004000:	02f00793          	li	a5,47
    80004004:	02f70263          	beq	a4,a5,80004028 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004008:	ffffe097          	auipc	ra,0xffffe
    8000400c:	99e080e7          	jalr	-1634(ra) # 800019a6 <myproc>
    80004010:	15053503          	ld	a0,336(a0)
    80004014:	00000097          	auipc	ra,0x0
    80004018:	9f6080e7          	jalr	-1546(ra) # 80003a0a <idup>
    8000401c:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000401e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004022:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004024:	4b85                	li	s7,1
    80004026:	a875                	j	800040e2 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80004028:	4585                	li	a1,1
    8000402a:	4505                	li	a0,1
    8000402c:	fffff097          	auipc	ra,0xfffff
    80004030:	6e8080e7          	jalr	1768(ra) # 80003714 <iget>
    80004034:	8a2a                	mv	s4,a0
    80004036:	b7e5                	j	8000401e <namex+0x42>
      iunlockput(ip);
    80004038:	8552                	mv	a0,s4
    8000403a:	00000097          	auipc	ra,0x0
    8000403e:	c70080e7          	jalr	-912(ra) # 80003caa <iunlockput>
      return 0;
    80004042:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004044:	8552                	mv	a0,s4
    80004046:	60e6                	ld	ra,88(sp)
    80004048:	6446                	ld	s0,80(sp)
    8000404a:	64a6                	ld	s1,72(sp)
    8000404c:	6906                	ld	s2,64(sp)
    8000404e:	79e2                	ld	s3,56(sp)
    80004050:	7a42                	ld	s4,48(sp)
    80004052:	7aa2                	ld	s5,40(sp)
    80004054:	7b02                	ld	s6,32(sp)
    80004056:	6be2                	ld	s7,24(sp)
    80004058:	6c42                	ld	s8,16(sp)
    8000405a:	6ca2                	ld	s9,8(sp)
    8000405c:	6125                	add	sp,sp,96
    8000405e:	8082                	ret
      iunlock(ip);
    80004060:	8552                	mv	a0,s4
    80004062:	00000097          	auipc	ra,0x0
    80004066:	aa8080e7          	jalr	-1368(ra) # 80003b0a <iunlock>
      return ip;
    8000406a:	bfe9                	j	80004044 <namex+0x68>
      iunlockput(ip);
    8000406c:	8552                	mv	a0,s4
    8000406e:	00000097          	auipc	ra,0x0
    80004072:	c3c080e7          	jalr	-964(ra) # 80003caa <iunlockput>
      return 0;
    80004076:	8a4e                	mv	s4,s3
    80004078:	b7f1                	j	80004044 <namex+0x68>
  len = path - s;
    8000407a:	40998633          	sub	a2,s3,s1
    8000407e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004082:	099c5863          	bge	s8,s9,80004112 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80004086:	4639                	li	a2,14
    80004088:	85a6                	mv	a1,s1
    8000408a:	8556                	mv	a0,s5
    8000408c:	ffffd097          	auipc	ra,0xffffd
    80004090:	c9e080e7          	jalr	-866(ra) # 80000d2a <memmove>
    80004094:	84ce                	mv	s1,s3
  while(*path == '/')
    80004096:	0004c783          	lbu	a5,0(s1)
    8000409a:	01279763          	bne	a5,s2,800040a8 <namex+0xcc>
    path++;
    8000409e:	0485                	add	s1,s1,1
  while(*path == '/')
    800040a0:	0004c783          	lbu	a5,0(s1)
    800040a4:	ff278de3          	beq	a5,s2,8000409e <namex+0xc2>
    ilock(ip);
    800040a8:	8552                	mv	a0,s4
    800040aa:	00000097          	auipc	ra,0x0
    800040ae:	99e080e7          	jalr	-1634(ra) # 80003a48 <ilock>
    if(ip->type != T_DIR){
    800040b2:	044a1783          	lh	a5,68(s4)
    800040b6:	f97791e3          	bne	a5,s7,80004038 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    800040ba:	000b0563          	beqz	s6,800040c4 <namex+0xe8>
    800040be:	0004c783          	lbu	a5,0(s1)
    800040c2:	dfd9                	beqz	a5,80004060 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    800040c4:	4601                	li	a2,0
    800040c6:	85d6                	mv	a1,s5
    800040c8:	8552                	mv	a0,s4
    800040ca:	00000097          	auipc	ra,0x0
    800040ce:	e62080e7          	jalr	-414(ra) # 80003f2c <dirlookup>
    800040d2:	89aa                	mv	s3,a0
    800040d4:	dd41                	beqz	a0,8000406c <namex+0x90>
    iunlockput(ip);
    800040d6:	8552                	mv	a0,s4
    800040d8:	00000097          	auipc	ra,0x0
    800040dc:	bd2080e7          	jalr	-1070(ra) # 80003caa <iunlockput>
    ip = next;
    800040e0:	8a4e                	mv	s4,s3
  while(*path == '/')
    800040e2:	0004c783          	lbu	a5,0(s1)
    800040e6:	01279763          	bne	a5,s2,800040f4 <namex+0x118>
    path++;
    800040ea:	0485                	add	s1,s1,1
  while(*path == '/')
    800040ec:	0004c783          	lbu	a5,0(s1)
    800040f0:	ff278de3          	beq	a5,s2,800040ea <namex+0x10e>
  if(*path == 0)
    800040f4:	cb9d                	beqz	a5,8000412a <namex+0x14e>
  while(*path != '/' && *path != 0)
    800040f6:	0004c783          	lbu	a5,0(s1)
    800040fa:	89a6                	mv	s3,s1
  len = path - s;
    800040fc:	4c81                	li	s9,0
    800040fe:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004100:	01278963          	beq	a5,s2,80004112 <namex+0x136>
    80004104:	dbbd                	beqz	a5,8000407a <namex+0x9e>
    path++;
    80004106:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    80004108:	0009c783          	lbu	a5,0(s3)
    8000410c:	ff279ce3          	bne	a5,s2,80004104 <namex+0x128>
    80004110:	b7ad                	j	8000407a <namex+0x9e>
    memmove(name, s, len);
    80004112:	2601                	sext.w	a2,a2
    80004114:	85a6                	mv	a1,s1
    80004116:	8556                	mv	a0,s5
    80004118:	ffffd097          	auipc	ra,0xffffd
    8000411c:	c12080e7          	jalr	-1006(ra) # 80000d2a <memmove>
    name[len] = 0;
    80004120:	9cd6                	add	s9,s9,s5
    80004122:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004126:	84ce                	mv	s1,s3
    80004128:	b7bd                	j	80004096 <namex+0xba>
  if(nameiparent){
    8000412a:	f00b0de3          	beqz	s6,80004044 <namex+0x68>
    iput(ip);
    8000412e:	8552                	mv	a0,s4
    80004130:	00000097          	auipc	ra,0x0
    80004134:	ad2080e7          	jalr	-1326(ra) # 80003c02 <iput>
    return 0;
    80004138:	4a01                	li	s4,0
    8000413a:	b729                	j	80004044 <namex+0x68>

000000008000413c <dirlink>:
{
    8000413c:	7139                	add	sp,sp,-64
    8000413e:	fc06                	sd	ra,56(sp)
    80004140:	f822                	sd	s0,48(sp)
    80004142:	f426                	sd	s1,40(sp)
    80004144:	f04a                	sd	s2,32(sp)
    80004146:	ec4e                	sd	s3,24(sp)
    80004148:	e852                	sd	s4,16(sp)
    8000414a:	0080                	add	s0,sp,64
    8000414c:	892a                	mv	s2,a0
    8000414e:	8a2e                	mv	s4,a1
    80004150:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004152:	4601                	li	a2,0
    80004154:	00000097          	auipc	ra,0x0
    80004158:	dd8080e7          	jalr	-552(ra) # 80003f2c <dirlookup>
    8000415c:	e93d                	bnez	a0,800041d2 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000415e:	04c92483          	lw	s1,76(s2)
    80004162:	c49d                	beqz	s1,80004190 <dirlink+0x54>
    80004164:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004166:	4741                	li	a4,16
    80004168:	86a6                	mv	a3,s1
    8000416a:	fc040613          	add	a2,s0,-64
    8000416e:	4581                	li	a1,0
    80004170:	854a                	mv	a0,s2
    80004172:	00000097          	auipc	ra,0x0
    80004176:	b8a080e7          	jalr	-1142(ra) # 80003cfc <readi>
    8000417a:	47c1                	li	a5,16
    8000417c:	06f51163          	bne	a0,a5,800041de <dirlink+0xa2>
    if(de.inum == 0)
    80004180:	fc045783          	lhu	a5,-64(s0)
    80004184:	c791                	beqz	a5,80004190 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004186:	24c1                	addw	s1,s1,16
    80004188:	04c92783          	lw	a5,76(s2)
    8000418c:	fcf4ede3          	bltu	s1,a5,80004166 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004190:	4639                	li	a2,14
    80004192:	85d2                	mv	a1,s4
    80004194:	fc240513          	add	a0,s0,-62
    80004198:	ffffd097          	auipc	ra,0xffffd
    8000419c:	c42080e7          	jalr	-958(ra) # 80000dda <strncpy>
  de.inum = inum;
    800041a0:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041a4:	4741                	li	a4,16
    800041a6:	86a6                	mv	a3,s1
    800041a8:	fc040613          	add	a2,s0,-64
    800041ac:	4581                	li	a1,0
    800041ae:	854a                	mv	a0,s2
    800041b0:	00000097          	auipc	ra,0x0
    800041b4:	c44080e7          	jalr	-956(ra) # 80003df4 <writei>
    800041b8:	1541                	add	a0,a0,-16
    800041ba:	00a03533          	snez	a0,a0
    800041be:	40a00533          	neg	a0,a0
}
    800041c2:	70e2                	ld	ra,56(sp)
    800041c4:	7442                	ld	s0,48(sp)
    800041c6:	74a2                	ld	s1,40(sp)
    800041c8:	7902                	ld	s2,32(sp)
    800041ca:	69e2                	ld	s3,24(sp)
    800041cc:	6a42                	ld	s4,16(sp)
    800041ce:	6121                	add	sp,sp,64
    800041d0:	8082                	ret
    iput(ip);
    800041d2:	00000097          	auipc	ra,0x0
    800041d6:	a30080e7          	jalr	-1488(ra) # 80003c02 <iput>
    return -1;
    800041da:	557d                	li	a0,-1
    800041dc:	b7dd                	j	800041c2 <dirlink+0x86>
      panic("dirlink read");
    800041de:	00004517          	auipc	a0,0x4
    800041e2:	45a50513          	add	a0,a0,1114 # 80008638 <syscalls+0x1e8>
    800041e6:	ffffc097          	auipc	ra,0xffffc
    800041ea:	356080e7          	jalr	854(ra) # 8000053c <panic>

00000000800041ee <namei>:

struct inode*
namei(char *path)
{
    800041ee:	1101                	add	sp,sp,-32
    800041f0:	ec06                	sd	ra,24(sp)
    800041f2:	e822                	sd	s0,16(sp)
    800041f4:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800041f6:	fe040613          	add	a2,s0,-32
    800041fa:	4581                	li	a1,0
    800041fc:	00000097          	auipc	ra,0x0
    80004200:	de0080e7          	jalr	-544(ra) # 80003fdc <namex>
}
    80004204:	60e2                	ld	ra,24(sp)
    80004206:	6442                	ld	s0,16(sp)
    80004208:	6105                	add	sp,sp,32
    8000420a:	8082                	ret

000000008000420c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000420c:	1141                	add	sp,sp,-16
    8000420e:	e406                	sd	ra,8(sp)
    80004210:	e022                	sd	s0,0(sp)
    80004212:	0800                	add	s0,sp,16
    80004214:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004216:	4585                	li	a1,1
    80004218:	00000097          	auipc	ra,0x0
    8000421c:	dc4080e7          	jalr	-572(ra) # 80003fdc <namex>
}
    80004220:	60a2                	ld	ra,8(sp)
    80004222:	6402                	ld	s0,0(sp)
    80004224:	0141                	add	sp,sp,16
    80004226:	8082                	ret

0000000080004228 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004228:	1101                	add	sp,sp,-32
    8000422a:	ec06                	sd	ra,24(sp)
    8000422c:	e822                	sd	s0,16(sp)
    8000422e:	e426                	sd	s1,8(sp)
    80004230:	e04a                	sd	s2,0(sp)
    80004232:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004234:	0001d917          	auipc	s2,0x1d
    80004238:	51c90913          	add	s2,s2,1308 # 80021750 <log>
    8000423c:	01892583          	lw	a1,24(s2)
    80004240:	02892503          	lw	a0,40(s2)
    80004244:	fffff097          	auipc	ra,0xfffff
    80004248:	ff4080e7          	jalr	-12(ra) # 80003238 <bread>
    8000424c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000424e:	02c92603          	lw	a2,44(s2)
    80004252:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004254:	00c05f63          	blez	a2,80004272 <write_head+0x4a>
    80004258:	0001d717          	auipc	a4,0x1d
    8000425c:	52870713          	add	a4,a4,1320 # 80021780 <log+0x30>
    80004260:	87aa                	mv	a5,a0
    80004262:	060a                	sll	a2,a2,0x2
    80004264:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004266:	4314                	lw	a3,0(a4)
    80004268:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000426a:	0711                	add	a4,a4,4
    8000426c:	0791                	add	a5,a5,4
    8000426e:	fec79ce3          	bne	a5,a2,80004266 <write_head+0x3e>
  }
  bwrite(buf);
    80004272:	8526                	mv	a0,s1
    80004274:	fffff097          	auipc	ra,0xfffff
    80004278:	0b6080e7          	jalr	182(ra) # 8000332a <bwrite>
  brelse(buf);
    8000427c:	8526                	mv	a0,s1
    8000427e:	fffff097          	auipc	ra,0xfffff
    80004282:	0ea080e7          	jalr	234(ra) # 80003368 <brelse>
}
    80004286:	60e2                	ld	ra,24(sp)
    80004288:	6442                	ld	s0,16(sp)
    8000428a:	64a2                	ld	s1,8(sp)
    8000428c:	6902                	ld	s2,0(sp)
    8000428e:	6105                	add	sp,sp,32
    80004290:	8082                	ret

0000000080004292 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004292:	0001d797          	auipc	a5,0x1d
    80004296:	4ea7a783          	lw	a5,1258(a5) # 8002177c <log+0x2c>
    8000429a:	0af05d63          	blez	a5,80004354 <install_trans+0xc2>
{
    8000429e:	7139                	add	sp,sp,-64
    800042a0:	fc06                	sd	ra,56(sp)
    800042a2:	f822                	sd	s0,48(sp)
    800042a4:	f426                	sd	s1,40(sp)
    800042a6:	f04a                	sd	s2,32(sp)
    800042a8:	ec4e                	sd	s3,24(sp)
    800042aa:	e852                	sd	s4,16(sp)
    800042ac:	e456                	sd	s5,8(sp)
    800042ae:	e05a                	sd	s6,0(sp)
    800042b0:	0080                	add	s0,sp,64
    800042b2:	8b2a                	mv	s6,a0
    800042b4:	0001da97          	auipc	s5,0x1d
    800042b8:	4cca8a93          	add	s5,s5,1228 # 80021780 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042bc:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800042be:	0001d997          	auipc	s3,0x1d
    800042c2:	49298993          	add	s3,s3,1170 # 80021750 <log>
    800042c6:	a00d                	j	800042e8 <install_trans+0x56>
    brelse(lbuf);
    800042c8:	854a                	mv	a0,s2
    800042ca:	fffff097          	auipc	ra,0xfffff
    800042ce:	09e080e7          	jalr	158(ra) # 80003368 <brelse>
    brelse(dbuf);
    800042d2:	8526                	mv	a0,s1
    800042d4:	fffff097          	auipc	ra,0xfffff
    800042d8:	094080e7          	jalr	148(ra) # 80003368 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042dc:	2a05                	addw	s4,s4,1
    800042de:	0a91                	add	s5,s5,4
    800042e0:	02c9a783          	lw	a5,44(s3)
    800042e4:	04fa5e63          	bge	s4,a5,80004340 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800042e8:	0189a583          	lw	a1,24(s3)
    800042ec:	014585bb          	addw	a1,a1,s4
    800042f0:	2585                	addw	a1,a1,1
    800042f2:	0289a503          	lw	a0,40(s3)
    800042f6:	fffff097          	auipc	ra,0xfffff
    800042fa:	f42080e7          	jalr	-190(ra) # 80003238 <bread>
    800042fe:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004300:	000aa583          	lw	a1,0(s5)
    80004304:	0289a503          	lw	a0,40(s3)
    80004308:	fffff097          	auipc	ra,0xfffff
    8000430c:	f30080e7          	jalr	-208(ra) # 80003238 <bread>
    80004310:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004312:	40000613          	li	a2,1024
    80004316:	05890593          	add	a1,s2,88
    8000431a:	05850513          	add	a0,a0,88
    8000431e:	ffffd097          	auipc	ra,0xffffd
    80004322:	a0c080e7          	jalr	-1524(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004326:	8526                	mv	a0,s1
    80004328:	fffff097          	auipc	ra,0xfffff
    8000432c:	002080e7          	jalr	2(ra) # 8000332a <bwrite>
    if(recovering == 0)
    80004330:	f80b1ce3          	bnez	s6,800042c8 <install_trans+0x36>
      bunpin(dbuf);
    80004334:	8526                	mv	a0,s1
    80004336:	fffff097          	auipc	ra,0xfffff
    8000433a:	10a080e7          	jalr	266(ra) # 80003440 <bunpin>
    8000433e:	b769                	j	800042c8 <install_trans+0x36>
}
    80004340:	70e2                	ld	ra,56(sp)
    80004342:	7442                	ld	s0,48(sp)
    80004344:	74a2                	ld	s1,40(sp)
    80004346:	7902                	ld	s2,32(sp)
    80004348:	69e2                	ld	s3,24(sp)
    8000434a:	6a42                	ld	s4,16(sp)
    8000434c:	6aa2                	ld	s5,8(sp)
    8000434e:	6b02                	ld	s6,0(sp)
    80004350:	6121                	add	sp,sp,64
    80004352:	8082                	ret
    80004354:	8082                	ret

0000000080004356 <initlog>:
{
    80004356:	7179                	add	sp,sp,-48
    80004358:	f406                	sd	ra,40(sp)
    8000435a:	f022                	sd	s0,32(sp)
    8000435c:	ec26                	sd	s1,24(sp)
    8000435e:	e84a                	sd	s2,16(sp)
    80004360:	e44e                	sd	s3,8(sp)
    80004362:	1800                	add	s0,sp,48
    80004364:	892a                	mv	s2,a0
    80004366:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004368:	0001d497          	auipc	s1,0x1d
    8000436c:	3e848493          	add	s1,s1,1000 # 80021750 <log>
    80004370:	00004597          	auipc	a1,0x4
    80004374:	2d858593          	add	a1,a1,728 # 80008648 <syscalls+0x1f8>
    80004378:	8526                	mv	a0,s1
    8000437a:	ffffc097          	auipc	ra,0xffffc
    8000437e:	7c8080e7          	jalr	1992(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    80004382:	0149a583          	lw	a1,20(s3)
    80004386:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004388:	0109a783          	lw	a5,16(s3)
    8000438c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000438e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004392:	854a                	mv	a0,s2
    80004394:	fffff097          	auipc	ra,0xfffff
    80004398:	ea4080e7          	jalr	-348(ra) # 80003238 <bread>
  log.lh.n = lh->n;
    8000439c:	4d30                	lw	a2,88(a0)
    8000439e:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800043a0:	00c05f63          	blez	a2,800043be <initlog+0x68>
    800043a4:	87aa                	mv	a5,a0
    800043a6:	0001d717          	auipc	a4,0x1d
    800043aa:	3da70713          	add	a4,a4,986 # 80021780 <log+0x30>
    800043ae:	060a                	sll	a2,a2,0x2
    800043b0:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800043b2:	4ff4                	lw	a3,92(a5)
    800043b4:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800043b6:	0791                	add	a5,a5,4
    800043b8:	0711                	add	a4,a4,4
    800043ba:	fec79ce3          	bne	a5,a2,800043b2 <initlog+0x5c>
  brelse(buf);
    800043be:	fffff097          	auipc	ra,0xfffff
    800043c2:	faa080e7          	jalr	-86(ra) # 80003368 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800043c6:	4505                	li	a0,1
    800043c8:	00000097          	auipc	ra,0x0
    800043cc:	eca080e7          	jalr	-310(ra) # 80004292 <install_trans>
  log.lh.n = 0;
    800043d0:	0001d797          	auipc	a5,0x1d
    800043d4:	3a07a623          	sw	zero,940(a5) # 8002177c <log+0x2c>
  write_head(); // clear the log
    800043d8:	00000097          	auipc	ra,0x0
    800043dc:	e50080e7          	jalr	-432(ra) # 80004228 <write_head>
}
    800043e0:	70a2                	ld	ra,40(sp)
    800043e2:	7402                	ld	s0,32(sp)
    800043e4:	64e2                	ld	s1,24(sp)
    800043e6:	6942                	ld	s2,16(sp)
    800043e8:	69a2                	ld	s3,8(sp)
    800043ea:	6145                	add	sp,sp,48
    800043ec:	8082                	ret

00000000800043ee <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800043ee:	1101                	add	sp,sp,-32
    800043f0:	ec06                	sd	ra,24(sp)
    800043f2:	e822                	sd	s0,16(sp)
    800043f4:	e426                	sd	s1,8(sp)
    800043f6:	e04a                	sd	s2,0(sp)
    800043f8:	1000                	add	s0,sp,32
  acquire(&log.lock);
    800043fa:	0001d517          	auipc	a0,0x1d
    800043fe:	35650513          	add	a0,a0,854 # 80021750 <log>
    80004402:	ffffc097          	auipc	ra,0xffffc
    80004406:	7d0080e7          	jalr	2000(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    8000440a:	0001d497          	auipc	s1,0x1d
    8000440e:	34648493          	add	s1,s1,838 # 80021750 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004412:	4979                	li	s2,30
    80004414:	a039                	j	80004422 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004416:	85a6                	mv	a1,s1
    80004418:	8526                	mv	a0,s1
    8000441a:	ffffe097          	auipc	ra,0xffffe
    8000441e:	cda080e7          	jalr	-806(ra) # 800020f4 <sleep>
    if(log.committing){
    80004422:	50dc                	lw	a5,36(s1)
    80004424:	fbed                	bnez	a5,80004416 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004426:	5098                	lw	a4,32(s1)
    80004428:	2705                	addw	a4,a4,1
    8000442a:	0027179b          	sllw	a5,a4,0x2
    8000442e:	9fb9                	addw	a5,a5,a4
    80004430:	0017979b          	sllw	a5,a5,0x1
    80004434:	54d4                	lw	a3,44(s1)
    80004436:	9fb5                	addw	a5,a5,a3
    80004438:	00f95963          	bge	s2,a5,8000444a <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000443c:	85a6                	mv	a1,s1
    8000443e:	8526                	mv	a0,s1
    80004440:	ffffe097          	auipc	ra,0xffffe
    80004444:	cb4080e7          	jalr	-844(ra) # 800020f4 <sleep>
    80004448:	bfe9                	j	80004422 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000444a:	0001d517          	auipc	a0,0x1d
    8000444e:	30650513          	add	a0,a0,774 # 80021750 <log>
    80004452:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004454:	ffffd097          	auipc	ra,0xffffd
    80004458:	832080e7          	jalr	-1998(ra) # 80000c86 <release>
      break;
    }
  }
}
    8000445c:	60e2                	ld	ra,24(sp)
    8000445e:	6442                	ld	s0,16(sp)
    80004460:	64a2                	ld	s1,8(sp)
    80004462:	6902                	ld	s2,0(sp)
    80004464:	6105                	add	sp,sp,32
    80004466:	8082                	ret

0000000080004468 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004468:	7139                	add	sp,sp,-64
    8000446a:	fc06                	sd	ra,56(sp)
    8000446c:	f822                	sd	s0,48(sp)
    8000446e:	f426                	sd	s1,40(sp)
    80004470:	f04a                	sd	s2,32(sp)
    80004472:	ec4e                	sd	s3,24(sp)
    80004474:	e852                	sd	s4,16(sp)
    80004476:	e456                	sd	s5,8(sp)
    80004478:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000447a:	0001d497          	auipc	s1,0x1d
    8000447e:	2d648493          	add	s1,s1,726 # 80021750 <log>
    80004482:	8526                	mv	a0,s1
    80004484:	ffffc097          	auipc	ra,0xffffc
    80004488:	74e080e7          	jalr	1870(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    8000448c:	509c                	lw	a5,32(s1)
    8000448e:	37fd                	addw	a5,a5,-1
    80004490:	0007891b          	sext.w	s2,a5
    80004494:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004496:	50dc                	lw	a5,36(s1)
    80004498:	e7b9                	bnez	a5,800044e6 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000449a:	04091e63          	bnez	s2,800044f6 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000449e:	0001d497          	auipc	s1,0x1d
    800044a2:	2b248493          	add	s1,s1,690 # 80021750 <log>
    800044a6:	4785                	li	a5,1
    800044a8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800044aa:	8526                	mv	a0,s1
    800044ac:	ffffc097          	auipc	ra,0xffffc
    800044b0:	7da080e7          	jalr	2010(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800044b4:	54dc                	lw	a5,44(s1)
    800044b6:	06f04763          	bgtz	a5,80004524 <end_op+0xbc>
    acquire(&log.lock);
    800044ba:	0001d497          	auipc	s1,0x1d
    800044be:	29648493          	add	s1,s1,662 # 80021750 <log>
    800044c2:	8526                	mv	a0,s1
    800044c4:	ffffc097          	auipc	ra,0xffffc
    800044c8:	70e080e7          	jalr	1806(ra) # 80000bd2 <acquire>
    log.committing = 0;
    800044cc:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800044d0:	8526                	mv	a0,s1
    800044d2:	ffffe097          	auipc	ra,0xffffe
    800044d6:	c86080e7          	jalr	-890(ra) # 80002158 <wakeup>
    release(&log.lock);
    800044da:	8526                	mv	a0,s1
    800044dc:	ffffc097          	auipc	ra,0xffffc
    800044e0:	7aa080e7          	jalr	1962(ra) # 80000c86 <release>
}
    800044e4:	a03d                	j	80004512 <end_op+0xaa>
    panic("log.committing");
    800044e6:	00004517          	auipc	a0,0x4
    800044ea:	16a50513          	add	a0,a0,362 # 80008650 <syscalls+0x200>
    800044ee:	ffffc097          	auipc	ra,0xffffc
    800044f2:	04e080e7          	jalr	78(ra) # 8000053c <panic>
    wakeup(&log);
    800044f6:	0001d497          	auipc	s1,0x1d
    800044fa:	25a48493          	add	s1,s1,602 # 80021750 <log>
    800044fe:	8526                	mv	a0,s1
    80004500:	ffffe097          	auipc	ra,0xffffe
    80004504:	c58080e7          	jalr	-936(ra) # 80002158 <wakeup>
  release(&log.lock);
    80004508:	8526                	mv	a0,s1
    8000450a:	ffffc097          	auipc	ra,0xffffc
    8000450e:	77c080e7          	jalr	1916(ra) # 80000c86 <release>
}
    80004512:	70e2                	ld	ra,56(sp)
    80004514:	7442                	ld	s0,48(sp)
    80004516:	74a2                	ld	s1,40(sp)
    80004518:	7902                	ld	s2,32(sp)
    8000451a:	69e2                	ld	s3,24(sp)
    8000451c:	6a42                	ld	s4,16(sp)
    8000451e:	6aa2                	ld	s5,8(sp)
    80004520:	6121                	add	sp,sp,64
    80004522:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004524:	0001da97          	auipc	s5,0x1d
    80004528:	25ca8a93          	add	s5,s5,604 # 80021780 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000452c:	0001da17          	auipc	s4,0x1d
    80004530:	224a0a13          	add	s4,s4,548 # 80021750 <log>
    80004534:	018a2583          	lw	a1,24(s4)
    80004538:	012585bb          	addw	a1,a1,s2
    8000453c:	2585                	addw	a1,a1,1
    8000453e:	028a2503          	lw	a0,40(s4)
    80004542:	fffff097          	auipc	ra,0xfffff
    80004546:	cf6080e7          	jalr	-778(ra) # 80003238 <bread>
    8000454a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000454c:	000aa583          	lw	a1,0(s5)
    80004550:	028a2503          	lw	a0,40(s4)
    80004554:	fffff097          	auipc	ra,0xfffff
    80004558:	ce4080e7          	jalr	-796(ra) # 80003238 <bread>
    8000455c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000455e:	40000613          	li	a2,1024
    80004562:	05850593          	add	a1,a0,88
    80004566:	05848513          	add	a0,s1,88
    8000456a:	ffffc097          	auipc	ra,0xffffc
    8000456e:	7c0080e7          	jalr	1984(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    80004572:	8526                	mv	a0,s1
    80004574:	fffff097          	auipc	ra,0xfffff
    80004578:	db6080e7          	jalr	-586(ra) # 8000332a <bwrite>
    brelse(from);
    8000457c:	854e                	mv	a0,s3
    8000457e:	fffff097          	auipc	ra,0xfffff
    80004582:	dea080e7          	jalr	-534(ra) # 80003368 <brelse>
    brelse(to);
    80004586:	8526                	mv	a0,s1
    80004588:	fffff097          	auipc	ra,0xfffff
    8000458c:	de0080e7          	jalr	-544(ra) # 80003368 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004590:	2905                	addw	s2,s2,1
    80004592:	0a91                	add	s5,s5,4
    80004594:	02ca2783          	lw	a5,44(s4)
    80004598:	f8f94ee3          	blt	s2,a5,80004534 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000459c:	00000097          	auipc	ra,0x0
    800045a0:	c8c080e7          	jalr	-884(ra) # 80004228 <write_head>
    install_trans(0); // Now install writes to home locations
    800045a4:	4501                	li	a0,0
    800045a6:	00000097          	auipc	ra,0x0
    800045aa:	cec080e7          	jalr	-788(ra) # 80004292 <install_trans>
    log.lh.n = 0;
    800045ae:	0001d797          	auipc	a5,0x1d
    800045b2:	1c07a723          	sw	zero,462(a5) # 8002177c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800045b6:	00000097          	auipc	ra,0x0
    800045ba:	c72080e7          	jalr	-910(ra) # 80004228 <write_head>
    800045be:	bdf5                	j	800044ba <end_op+0x52>

00000000800045c0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800045c0:	1101                	add	sp,sp,-32
    800045c2:	ec06                	sd	ra,24(sp)
    800045c4:	e822                	sd	s0,16(sp)
    800045c6:	e426                	sd	s1,8(sp)
    800045c8:	e04a                	sd	s2,0(sp)
    800045ca:	1000                	add	s0,sp,32
    800045cc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800045ce:	0001d917          	auipc	s2,0x1d
    800045d2:	18290913          	add	s2,s2,386 # 80021750 <log>
    800045d6:	854a                	mv	a0,s2
    800045d8:	ffffc097          	auipc	ra,0xffffc
    800045dc:	5fa080e7          	jalr	1530(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800045e0:	02c92603          	lw	a2,44(s2)
    800045e4:	47f5                	li	a5,29
    800045e6:	06c7c563          	blt	a5,a2,80004650 <log_write+0x90>
    800045ea:	0001d797          	auipc	a5,0x1d
    800045ee:	1827a783          	lw	a5,386(a5) # 8002176c <log+0x1c>
    800045f2:	37fd                	addw	a5,a5,-1
    800045f4:	04f65e63          	bge	a2,a5,80004650 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045f8:	0001d797          	auipc	a5,0x1d
    800045fc:	1787a783          	lw	a5,376(a5) # 80021770 <log+0x20>
    80004600:	06f05063          	blez	a5,80004660 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004604:	4781                	li	a5,0
    80004606:	06c05563          	blez	a2,80004670 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000460a:	44cc                	lw	a1,12(s1)
    8000460c:	0001d717          	auipc	a4,0x1d
    80004610:	17470713          	add	a4,a4,372 # 80021780 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004614:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004616:	4314                	lw	a3,0(a4)
    80004618:	04b68c63          	beq	a3,a1,80004670 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000461c:	2785                	addw	a5,a5,1
    8000461e:	0711                	add	a4,a4,4
    80004620:	fef61be3          	bne	a2,a5,80004616 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004624:	0621                	add	a2,a2,8
    80004626:	060a                	sll	a2,a2,0x2
    80004628:	0001d797          	auipc	a5,0x1d
    8000462c:	12878793          	add	a5,a5,296 # 80021750 <log>
    80004630:	97b2                	add	a5,a5,a2
    80004632:	44d8                	lw	a4,12(s1)
    80004634:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004636:	8526                	mv	a0,s1
    80004638:	fffff097          	auipc	ra,0xfffff
    8000463c:	dcc080e7          	jalr	-564(ra) # 80003404 <bpin>
    log.lh.n++;
    80004640:	0001d717          	auipc	a4,0x1d
    80004644:	11070713          	add	a4,a4,272 # 80021750 <log>
    80004648:	575c                	lw	a5,44(a4)
    8000464a:	2785                	addw	a5,a5,1
    8000464c:	d75c                	sw	a5,44(a4)
    8000464e:	a82d                	j	80004688 <log_write+0xc8>
    panic("too big a transaction");
    80004650:	00004517          	auipc	a0,0x4
    80004654:	01050513          	add	a0,a0,16 # 80008660 <syscalls+0x210>
    80004658:	ffffc097          	auipc	ra,0xffffc
    8000465c:	ee4080e7          	jalr	-284(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    80004660:	00004517          	auipc	a0,0x4
    80004664:	01850513          	add	a0,a0,24 # 80008678 <syscalls+0x228>
    80004668:	ffffc097          	auipc	ra,0xffffc
    8000466c:	ed4080e7          	jalr	-300(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    80004670:	00878693          	add	a3,a5,8
    80004674:	068a                	sll	a3,a3,0x2
    80004676:	0001d717          	auipc	a4,0x1d
    8000467a:	0da70713          	add	a4,a4,218 # 80021750 <log>
    8000467e:	9736                	add	a4,a4,a3
    80004680:	44d4                	lw	a3,12(s1)
    80004682:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004684:	faf609e3          	beq	a2,a5,80004636 <log_write+0x76>
  }
  release(&log.lock);
    80004688:	0001d517          	auipc	a0,0x1d
    8000468c:	0c850513          	add	a0,a0,200 # 80021750 <log>
    80004690:	ffffc097          	auipc	ra,0xffffc
    80004694:	5f6080e7          	jalr	1526(ra) # 80000c86 <release>
}
    80004698:	60e2                	ld	ra,24(sp)
    8000469a:	6442                	ld	s0,16(sp)
    8000469c:	64a2                	ld	s1,8(sp)
    8000469e:	6902                	ld	s2,0(sp)
    800046a0:	6105                	add	sp,sp,32
    800046a2:	8082                	ret

00000000800046a4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800046a4:	1101                	add	sp,sp,-32
    800046a6:	ec06                	sd	ra,24(sp)
    800046a8:	e822                	sd	s0,16(sp)
    800046aa:	e426                	sd	s1,8(sp)
    800046ac:	e04a                	sd	s2,0(sp)
    800046ae:	1000                	add	s0,sp,32
    800046b0:	84aa                	mv	s1,a0
    800046b2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800046b4:	00004597          	auipc	a1,0x4
    800046b8:	fe458593          	add	a1,a1,-28 # 80008698 <syscalls+0x248>
    800046bc:	0521                	add	a0,a0,8
    800046be:	ffffc097          	auipc	ra,0xffffc
    800046c2:	484080e7          	jalr	1156(ra) # 80000b42 <initlock>
  lk->name = name;
    800046c6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800046ca:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046ce:	0204a423          	sw	zero,40(s1)
}
    800046d2:	60e2                	ld	ra,24(sp)
    800046d4:	6442                	ld	s0,16(sp)
    800046d6:	64a2                	ld	s1,8(sp)
    800046d8:	6902                	ld	s2,0(sp)
    800046da:	6105                	add	sp,sp,32
    800046dc:	8082                	ret

00000000800046de <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800046de:	1101                	add	sp,sp,-32
    800046e0:	ec06                	sd	ra,24(sp)
    800046e2:	e822                	sd	s0,16(sp)
    800046e4:	e426                	sd	s1,8(sp)
    800046e6:	e04a                	sd	s2,0(sp)
    800046e8:	1000                	add	s0,sp,32
    800046ea:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046ec:	00850913          	add	s2,a0,8
    800046f0:	854a                	mv	a0,s2
    800046f2:	ffffc097          	auipc	ra,0xffffc
    800046f6:	4e0080e7          	jalr	1248(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    800046fa:	409c                	lw	a5,0(s1)
    800046fc:	cb89                	beqz	a5,8000470e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800046fe:	85ca                	mv	a1,s2
    80004700:	8526                	mv	a0,s1
    80004702:	ffffe097          	auipc	ra,0xffffe
    80004706:	9f2080e7          	jalr	-1550(ra) # 800020f4 <sleep>
  while (lk->locked) {
    8000470a:	409c                	lw	a5,0(s1)
    8000470c:	fbed                	bnez	a5,800046fe <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000470e:	4785                	li	a5,1
    80004710:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004712:	ffffd097          	auipc	ra,0xffffd
    80004716:	294080e7          	jalr	660(ra) # 800019a6 <myproc>
    8000471a:	591c                	lw	a5,48(a0)
    8000471c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000471e:	854a                	mv	a0,s2
    80004720:	ffffc097          	auipc	ra,0xffffc
    80004724:	566080e7          	jalr	1382(ra) # 80000c86 <release>
}
    80004728:	60e2                	ld	ra,24(sp)
    8000472a:	6442                	ld	s0,16(sp)
    8000472c:	64a2                	ld	s1,8(sp)
    8000472e:	6902                	ld	s2,0(sp)
    80004730:	6105                	add	sp,sp,32
    80004732:	8082                	ret

0000000080004734 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004734:	1101                	add	sp,sp,-32
    80004736:	ec06                	sd	ra,24(sp)
    80004738:	e822                	sd	s0,16(sp)
    8000473a:	e426                	sd	s1,8(sp)
    8000473c:	e04a                	sd	s2,0(sp)
    8000473e:	1000                	add	s0,sp,32
    80004740:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004742:	00850913          	add	s2,a0,8
    80004746:	854a                	mv	a0,s2
    80004748:	ffffc097          	auipc	ra,0xffffc
    8000474c:	48a080e7          	jalr	1162(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    80004750:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004754:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004758:	8526                	mv	a0,s1
    8000475a:	ffffe097          	auipc	ra,0xffffe
    8000475e:	9fe080e7          	jalr	-1538(ra) # 80002158 <wakeup>
  release(&lk->lk);
    80004762:	854a                	mv	a0,s2
    80004764:	ffffc097          	auipc	ra,0xffffc
    80004768:	522080e7          	jalr	1314(ra) # 80000c86 <release>
}
    8000476c:	60e2                	ld	ra,24(sp)
    8000476e:	6442                	ld	s0,16(sp)
    80004770:	64a2                	ld	s1,8(sp)
    80004772:	6902                	ld	s2,0(sp)
    80004774:	6105                	add	sp,sp,32
    80004776:	8082                	ret

0000000080004778 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004778:	7179                	add	sp,sp,-48
    8000477a:	f406                	sd	ra,40(sp)
    8000477c:	f022                	sd	s0,32(sp)
    8000477e:	ec26                	sd	s1,24(sp)
    80004780:	e84a                	sd	s2,16(sp)
    80004782:	e44e                	sd	s3,8(sp)
    80004784:	1800                	add	s0,sp,48
    80004786:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004788:	00850913          	add	s2,a0,8
    8000478c:	854a                	mv	a0,s2
    8000478e:	ffffc097          	auipc	ra,0xffffc
    80004792:	444080e7          	jalr	1092(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004796:	409c                	lw	a5,0(s1)
    80004798:	ef99                	bnez	a5,800047b6 <holdingsleep+0x3e>
    8000479a:	4481                	li	s1,0
  release(&lk->lk);
    8000479c:	854a                	mv	a0,s2
    8000479e:	ffffc097          	auipc	ra,0xffffc
    800047a2:	4e8080e7          	jalr	1256(ra) # 80000c86 <release>
  return r;
}
    800047a6:	8526                	mv	a0,s1
    800047a8:	70a2                	ld	ra,40(sp)
    800047aa:	7402                	ld	s0,32(sp)
    800047ac:	64e2                	ld	s1,24(sp)
    800047ae:	6942                	ld	s2,16(sp)
    800047b0:	69a2                	ld	s3,8(sp)
    800047b2:	6145                	add	sp,sp,48
    800047b4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800047b6:	0284a983          	lw	s3,40(s1)
    800047ba:	ffffd097          	auipc	ra,0xffffd
    800047be:	1ec080e7          	jalr	492(ra) # 800019a6 <myproc>
    800047c2:	5904                	lw	s1,48(a0)
    800047c4:	413484b3          	sub	s1,s1,s3
    800047c8:	0014b493          	seqz	s1,s1
    800047cc:	bfc1                	j	8000479c <holdingsleep+0x24>

00000000800047ce <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800047ce:	1141                	add	sp,sp,-16
    800047d0:	e406                	sd	ra,8(sp)
    800047d2:	e022                	sd	s0,0(sp)
    800047d4:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800047d6:	00004597          	auipc	a1,0x4
    800047da:	ed258593          	add	a1,a1,-302 # 800086a8 <syscalls+0x258>
    800047de:	0001d517          	auipc	a0,0x1d
    800047e2:	0d250513          	add	a0,a0,210 # 800218b0 <ftable>
    800047e6:	ffffc097          	auipc	ra,0xffffc
    800047ea:	35c080e7          	jalr	860(ra) # 80000b42 <initlock>
  initlock(&readcountlock, "readcount");
    800047ee:	00004597          	auipc	a1,0x4
    800047f2:	ec258593          	add	a1,a1,-318 # 800086b0 <syscalls+0x260>
    800047f6:	0001d517          	auipc	a0,0x1d
    800047fa:	00250513          	add	a0,a0,2 # 800217f8 <readcountlock>
    800047fe:	ffffc097          	auipc	ra,0xffffc
    80004802:	344080e7          	jalr	836(ra) # 80000b42 <initlock>
}
    80004806:	60a2                	ld	ra,8(sp)
    80004808:	6402                	ld	s0,0(sp)
    8000480a:	0141                	add	sp,sp,16
    8000480c:	8082                	ret

000000008000480e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000480e:	1101                	add	sp,sp,-32
    80004810:	ec06                	sd	ra,24(sp)
    80004812:	e822                	sd	s0,16(sp)
    80004814:	e426                	sd	s1,8(sp)
    80004816:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004818:	0001d517          	auipc	a0,0x1d
    8000481c:	09850513          	add	a0,a0,152 # 800218b0 <ftable>
    80004820:	ffffc097          	auipc	ra,0xffffc
    80004824:	3b2080e7          	jalr	946(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004828:	0001d497          	auipc	s1,0x1d
    8000482c:	0a048493          	add	s1,s1,160 # 800218c8 <ftable+0x18>
    80004830:	0001e717          	auipc	a4,0x1e
    80004834:	03870713          	add	a4,a4,56 # 80022868 <disk>
    if(f->ref == 0){
    80004838:	40dc                	lw	a5,4(s1)
    8000483a:	cf99                	beqz	a5,80004858 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000483c:	02848493          	add	s1,s1,40
    80004840:	fee49ce3          	bne	s1,a4,80004838 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004844:	0001d517          	auipc	a0,0x1d
    80004848:	06c50513          	add	a0,a0,108 # 800218b0 <ftable>
    8000484c:	ffffc097          	auipc	ra,0xffffc
    80004850:	43a080e7          	jalr	1082(ra) # 80000c86 <release>
  return 0;
    80004854:	4481                	li	s1,0
    80004856:	a819                	j	8000486c <filealloc+0x5e>
      f->ref = 1;
    80004858:	4785                	li	a5,1
    8000485a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000485c:	0001d517          	auipc	a0,0x1d
    80004860:	05450513          	add	a0,a0,84 # 800218b0 <ftable>
    80004864:	ffffc097          	auipc	ra,0xffffc
    80004868:	422080e7          	jalr	1058(ra) # 80000c86 <release>
}
    8000486c:	8526                	mv	a0,s1
    8000486e:	60e2                	ld	ra,24(sp)
    80004870:	6442                	ld	s0,16(sp)
    80004872:	64a2                	ld	s1,8(sp)
    80004874:	6105                	add	sp,sp,32
    80004876:	8082                	ret

0000000080004878 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004878:	1101                	add	sp,sp,-32
    8000487a:	ec06                	sd	ra,24(sp)
    8000487c:	e822                	sd	s0,16(sp)
    8000487e:	e426                	sd	s1,8(sp)
    80004880:	1000                	add	s0,sp,32
    80004882:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004884:	0001d517          	auipc	a0,0x1d
    80004888:	02c50513          	add	a0,a0,44 # 800218b0 <ftable>
    8000488c:	ffffc097          	auipc	ra,0xffffc
    80004890:	346080e7          	jalr	838(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004894:	40dc                	lw	a5,4(s1)
    80004896:	02f05263          	blez	a5,800048ba <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000489a:	2785                	addw	a5,a5,1
    8000489c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000489e:	0001d517          	auipc	a0,0x1d
    800048a2:	01250513          	add	a0,a0,18 # 800218b0 <ftable>
    800048a6:	ffffc097          	auipc	ra,0xffffc
    800048aa:	3e0080e7          	jalr	992(ra) # 80000c86 <release>
  return f;
}
    800048ae:	8526                	mv	a0,s1
    800048b0:	60e2                	ld	ra,24(sp)
    800048b2:	6442                	ld	s0,16(sp)
    800048b4:	64a2                	ld	s1,8(sp)
    800048b6:	6105                	add	sp,sp,32
    800048b8:	8082                	ret
    panic("filedup");
    800048ba:	00004517          	auipc	a0,0x4
    800048be:	e0650513          	add	a0,a0,-506 # 800086c0 <syscalls+0x270>
    800048c2:	ffffc097          	auipc	ra,0xffffc
    800048c6:	c7a080e7          	jalr	-902(ra) # 8000053c <panic>

00000000800048ca <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800048ca:	7139                	add	sp,sp,-64
    800048cc:	fc06                	sd	ra,56(sp)
    800048ce:	f822                	sd	s0,48(sp)
    800048d0:	f426                	sd	s1,40(sp)
    800048d2:	f04a                	sd	s2,32(sp)
    800048d4:	ec4e                	sd	s3,24(sp)
    800048d6:	e852                	sd	s4,16(sp)
    800048d8:	e456                	sd	s5,8(sp)
    800048da:	0080                	add	s0,sp,64
    800048dc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800048de:	0001d517          	auipc	a0,0x1d
    800048e2:	fd250513          	add	a0,a0,-46 # 800218b0 <ftable>
    800048e6:	ffffc097          	auipc	ra,0xffffc
    800048ea:	2ec080e7          	jalr	748(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800048ee:	40dc                	lw	a5,4(s1)
    800048f0:	06f05163          	blez	a5,80004952 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800048f4:	37fd                	addw	a5,a5,-1
    800048f6:	0007871b          	sext.w	a4,a5
    800048fa:	c0dc                	sw	a5,4(s1)
    800048fc:	06e04363          	bgtz	a4,80004962 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004900:	0004a903          	lw	s2,0(s1)
    80004904:	0094ca83          	lbu	s5,9(s1)
    80004908:	0104ba03          	ld	s4,16(s1)
    8000490c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004910:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004914:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004918:	0001d517          	auipc	a0,0x1d
    8000491c:	f9850513          	add	a0,a0,-104 # 800218b0 <ftable>
    80004920:	ffffc097          	auipc	ra,0xffffc
    80004924:	366080e7          	jalr	870(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    80004928:	4785                	li	a5,1
    8000492a:	04f90d63          	beq	s2,a5,80004984 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000492e:	3979                	addw	s2,s2,-2
    80004930:	4785                	li	a5,1
    80004932:	0527e063          	bltu	a5,s2,80004972 <fileclose+0xa8>
    begin_op();
    80004936:	00000097          	auipc	ra,0x0
    8000493a:	ab8080e7          	jalr	-1352(ra) # 800043ee <begin_op>
    iput(ff.ip);
    8000493e:	854e                	mv	a0,s3
    80004940:	fffff097          	auipc	ra,0xfffff
    80004944:	2c2080e7          	jalr	706(ra) # 80003c02 <iput>
    end_op();
    80004948:	00000097          	auipc	ra,0x0
    8000494c:	b20080e7          	jalr	-1248(ra) # 80004468 <end_op>
    80004950:	a00d                	j	80004972 <fileclose+0xa8>
    panic("fileclose");
    80004952:	00004517          	auipc	a0,0x4
    80004956:	d7650513          	add	a0,a0,-650 # 800086c8 <syscalls+0x278>
    8000495a:	ffffc097          	auipc	ra,0xffffc
    8000495e:	be2080e7          	jalr	-1054(ra) # 8000053c <panic>
    release(&ftable.lock);
    80004962:	0001d517          	auipc	a0,0x1d
    80004966:	f4e50513          	add	a0,a0,-178 # 800218b0 <ftable>
    8000496a:	ffffc097          	auipc	ra,0xffffc
    8000496e:	31c080e7          	jalr	796(ra) # 80000c86 <release>
  }
}
    80004972:	70e2                	ld	ra,56(sp)
    80004974:	7442                	ld	s0,48(sp)
    80004976:	74a2                	ld	s1,40(sp)
    80004978:	7902                	ld	s2,32(sp)
    8000497a:	69e2                	ld	s3,24(sp)
    8000497c:	6a42                	ld	s4,16(sp)
    8000497e:	6aa2                	ld	s5,8(sp)
    80004980:	6121                	add	sp,sp,64
    80004982:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004984:	85d6                	mv	a1,s5
    80004986:	8552                	mv	a0,s4
    80004988:	00000097          	auipc	ra,0x0
    8000498c:	348080e7          	jalr	840(ra) # 80004cd0 <pipeclose>
    80004990:	b7cd                	j	80004972 <fileclose+0xa8>

0000000080004992 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004992:	715d                	add	sp,sp,-80
    80004994:	e486                	sd	ra,72(sp)
    80004996:	e0a2                	sd	s0,64(sp)
    80004998:	fc26                	sd	s1,56(sp)
    8000499a:	f84a                	sd	s2,48(sp)
    8000499c:	f44e                	sd	s3,40(sp)
    8000499e:	0880                	add	s0,sp,80
    800049a0:	84aa                	mv	s1,a0
    800049a2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800049a4:	ffffd097          	auipc	ra,0xffffd
    800049a8:	002080e7          	jalr	2(ra) # 800019a6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800049ac:	409c                	lw	a5,0(s1)
    800049ae:	37f9                	addw	a5,a5,-2
    800049b0:	4705                	li	a4,1
    800049b2:	04f76763          	bltu	a4,a5,80004a00 <filestat+0x6e>
    800049b6:	892a                	mv	s2,a0
    ilock(f->ip);
    800049b8:	6c88                	ld	a0,24(s1)
    800049ba:	fffff097          	auipc	ra,0xfffff
    800049be:	08e080e7          	jalr	142(ra) # 80003a48 <ilock>
    stati(f->ip, &st);
    800049c2:	fb840593          	add	a1,s0,-72
    800049c6:	6c88                	ld	a0,24(s1)
    800049c8:	fffff097          	auipc	ra,0xfffff
    800049cc:	30a080e7          	jalr	778(ra) # 80003cd2 <stati>
    iunlock(f->ip);
    800049d0:	6c88                	ld	a0,24(s1)
    800049d2:	fffff097          	auipc	ra,0xfffff
    800049d6:	138080e7          	jalr	312(ra) # 80003b0a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800049da:	46e1                	li	a3,24
    800049dc:	fb840613          	add	a2,s0,-72
    800049e0:	85ce                	mv	a1,s3
    800049e2:	05093503          	ld	a0,80(s2)
    800049e6:	ffffd097          	auipc	ra,0xffffd
    800049ea:	c80080e7          	jalr	-896(ra) # 80001666 <copyout>
    800049ee:	41f5551b          	sraw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800049f2:	60a6                	ld	ra,72(sp)
    800049f4:	6406                	ld	s0,64(sp)
    800049f6:	74e2                	ld	s1,56(sp)
    800049f8:	7942                	ld	s2,48(sp)
    800049fa:	79a2                	ld	s3,40(sp)
    800049fc:	6161                	add	sp,sp,80
    800049fe:	8082                	ret
  return -1;
    80004a00:	557d                	li	a0,-1
    80004a02:	bfc5                	j	800049f2 <filestat+0x60>

0000000080004a04 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004a04:	7179                	add	sp,sp,-48
    80004a06:	f406                	sd	ra,40(sp)
    80004a08:	f022                	sd	s0,32(sp)
    80004a0a:	ec26                	sd	s1,24(sp)
    80004a0c:	e84a                	sd	s2,16(sp)
    80004a0e:	e44e                	sd	s3,8(sp)
    80004a10:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004a12:	00854783          	lbu	a5,8(a0)
    80004a16:	c3d5                	beqz	a5,80004aba <fileread+0xb6>
    80004a18:	84aa                	mv	s1,a0
    80004a1a:	89ae                	mv	s3,a1
    80004a1c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a1e:	411c                	lw	a5,0(a0)
    80004a20:	4705                	li	a4,1
    80004a22:	04e78963          	beq	a5,a4,80004a74 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a26:	470d                	li	a4,3
    80004a28:	04e78d63          	beq	a5,a4,80004a82 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a2c:	4709                	li	a4,2
    80004a2e:	06e79e63          	bne	a5,a4,80004aaa <fileread+0xa6>
    ilock(f->ip);
    80004a32:	6d08                	ld	a0,24(a0)
    80004a34:	fffff097          	auipc	ra,0xfffff
    80004a38:	014080e7          	jalr	20(ra) # 80003a48 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004a3c:	874a                	mv	a4,s2
    80004a3e:	5094                	lw	a3,32(s1)
    80004a40:	864e                	mv	a2,s3
    80004a42:	4585                	li	a1,1
    80004a44:	6c88                	ld	a0,24(s1)
    80004a46:	fffff097          	auipc	ra,0xfffff
    80004a4a:	2b6080e7          	jalr	694(ra) # 80003cfc <readi>
    80004a4e:	892a                	mv	s2,a0
    80004a50:	00a05563          	blez	a0,80004a5a <fileread+0x56>
      f->off += r;
    80004a54:	509c                	lw	a5,32(s1)
    80004a56:	9fa9                	addw	a5,a5,a0
    80004a58:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a5a:	6c88                	ld	a0,24(s1)
    80004a5c:	fffff097          	auipc	ra,0xfffff
    80004a60:	0ae080e7          	jalr	174(ra) # 80003b0a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004a64:	854a                	mv	a0,s2
    80004a66:	70a2                	ld	ra,40(sp)
    80004a68:	7402                	ld	s0,32(sp)
    80004a6a:	64e2                	ld	s1,24(sp)
    80004a6c:	6942                	ld	s2,16(sp)
    80004a6e:	69a2                	ld	s3,8(sp)
    80004a70:	6145                	add	sp,sp,48
    80004a72:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a74:	6908                	ld	a0,16(a0)
    80004a76:	00000097          	auipc	ra,0x0
    80004a7a:	3c2080e7          	jalr	962(ra) # 80004e38 <piperead>
    80004a7e:	892a                	mv	s2,a0
    80004a80:	b7d5                	j	80004a64 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a82:	02451783          	lh	a5,36(a0)
    80004a86:	03079693          	sll	a3,a5,0x30
    80004a8a:	92c1                	srl	a3,a3,0x30
    80004a8c:	4725                	li	a4,9
    80004a8e:	02d76863          	bltu	a4,a3,80004abe <fileread+0xba>
    80004a92:	0792                	sll	a5,a5,0x4
    80004a94:	0001d717          	auipc	a4,0x1d
    80004a98:	d6470713          	add	a4,a4,-668 # 800217f8 <readcountlock>
    80004a9c:	97ba                	add	a5,a5,a4
    80004a9e:	6f9c                	ld	a5,24(a5)
    80004aa0:	c38d                	beqz	a5,80004ac2 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004aa2:	4505                	li	a0,1
    80004aa4:	9782                	jalr	a5
    80004aa6:	892a                	mv	s2,a0
    80004aa8:	bf75                	j	80004a64 <fileread+0x60>
    panic("fileread");
    80004aaa:	00004517          	auipc	a0,0x4
    80004aae:	c2e50513          	add	a0,a0,-978 # 800086d8 <syscalls+0x288>
    80004ab2:	ffffc097          	auipc	ra,0xffffc
    80004ab6:	a8a080e7          	jalr	-1398(ra) # 8000053c <panic>
    return -1;
    80004aba:	597d                	li	s2,-1
    80004abc:	b765                	j	80004a64 <fileread+0x60>
      return -1;
    80004abe:	597d                	li	s2,-1
    80004ac0:	b755                	j	80004a64 <fileread+0x60>
    80004ac2:	597d                	li	s2,-1
    80004ac4:	b745                	j	80004a64 <fileread+0x60>

0000000080004ac6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004ac6:	00954783          	lbu	a5,9(a0)
    80004aca:	10078e63          	beqz	a5,80004be6 <filewrite+0x120>
{
    80004ace:	715d                	add	sp,sp,-80
    80004ad0:	e486                	sd	ra,72(sp)
    80004ad2:	e0a2                	sd	s0,64(sp)
    80004ad4:	fc26                	sd	s1,56(sp)
    80004ad6:	f84a                	sd	s2,48(sp)
    80004ad8:	f44e                	sd	s3,40(sp)
    80004ada:	f052                	sd	s4,32(sp)
    80004adc:	ec56                	sd	s5,24(sp)
    80004ade:	e85a                	sd	s6,16(sp)
    80004ae0:	e45e                	sd	s7,8(sp)
    80004ae2:	e062                	sd	s8,0(sp)
    80004ae4:	0880                	add	s0,sp,80
    80004ae6:	892a                	mv	s2,a0
    80004ae8:	8b2e                	mv	s6,a1
    80004aea:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004aec:	411c                	lw	a5,0(a0)
    80004aee:	4705                	li	a4,1
    80004af0:	02e78263          	beq	a5,a4,80004b14 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004af4:	470d                	li	a4,3
    80004af6:	02e78563          	beq	a5,a4,80004b20 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004afa:	4709                	li	a4,2
    80004afc:	0ce79d63          	bne	a5,a4,80004bd6 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004b00:	0ac05b63          	blez	a2,80004bb6 <filewrite+0xf0>
    int i = 0;
    80004b04:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004b06:	6b85                	lui	s7,0x1
    80004b08:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004b0c:	6c05                	lui	s8,0x1
    80004b0e:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004b12:	a851                	j	80004ba6 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004b14:	6908                	ld	a0,16(a0)
    80004b16:	00000097          	auipc	ra,0x0
    80004b1a:	22a080e7          	jalr	554(ra) # 80004d40 <pipewrite>
    80004b1e:	a045                	j	80004bbe <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004b20:	02451783          	lh	a5,36(a0)
    80004b24:	03079693          	sll	a3,a5,0x30
    80004b28:	92c1                	srl	a3,a3,0x30
    80004b2a:	4725                	li	a4,9
    80004b2c:	0ad76f63          	bltu	a4,a3,80004bea <filewrite+0x124>
    80004b30:	0792                	sll	a5,a5,0x4
    80004b32:	0001d717          	auipc	a4,0x1d
    80004b36:	cc670713          	add	a4,a4,-826 # 800217f8 <readcountlock>
    80004b3a:	97ba                	add	a5,a5,a4
    80004b3c:	739c                	ld	a5,32(a5)
    80004b3e:	cbc5                	beqz	a5,80004bee <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004b40:	4505                	li	a0,1
    80004b42:	9782                	jalr	a5
    80004b44:	a8ad                	j	80004bbe <filewrite+0xf8>
      if(n1 > max)
    80004b46:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004b4a:	00000097          	auipc	ra,0x0
    80004b4e:	8a4080e7          	jalr	-1884(ra) # 800043ee <begin_op>
      ilock(f->ip);
    80004b52:	01893503          	ld	a0,24(s2)
    80004b56:	fffff097          	auipc	ra,0xfffff
    80004b5a:	ef2080e7          	jalr	-270(ra) # 80003a48 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b5e:	8756                	mv	a4,s5
    80004b60:	02092683          	lw	a3,32(s2)
    80004b64:	01698633          	add	a2,s3,s6
    80004b68:	4585                	li	a1,1
    80004b6a:	01893503          	ld	a0,24(s2)
    80004b6e:	fffff097          	auipc	ra,0xfffff
    80004b72:	286080e7          	jalr	646(ra) # 80003df4 <writei>
    80004b76:	84aa                	mv	s1,a0
    80004b78:	00a05763          	blez	a0,80004b86 <filewrite+0xc0>
        f->off += r;
    80004b7c:	02092783          	lw	a5,32(s2)
    80004b80:	9fa9                	addw	a5,a5,a0
    80004b82:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b86:	01893503          	ld	a0,24(s2)
    80004b8a:	fffff097          	auipc	ra,0xfffff
    80004b8e:	f80080e7          	jalr	-128(ra) # 80003b0a <iunlock>
      end_op();
    80004b92:	00000097          	auipc	ra,0x0
    80004b96:	8d6080e7          	jalr	-1834(ra) # 80004468 <end_op>

      if(r != n1){
    80004b9a:	009a9f63          	bne	s5,s1,80004bb8 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80004b9e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ba2:	0149db63          	bge	s3,s4,80004bb8 <filewrite+0xf2>
      int n1 = n - i;
    80004ba6:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004baa:	0004879b          	sext.w	a5,s1
    80004bae:	f8fbdce3          	bge	s7,a5,80004b46 <filewrite+0x80>
    80004bb2:	84e2                	mv	s1,s8
    80004bb4:	bf49                	j	80004b46 <filewrite+0x80>
    int i = 0;
    80004bb6:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004bb8:	033a1d63          	bne	s4,s3,80004bf2 <filewrite+0x12c>
    80004bbc:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004bbe:	60a6                	ld	ra,72(sp)
    80004bc0:	6406                	ld	s0,64(sp)
    80004bc2:	74e2                	ld	s1,56(sp)
    80004bc4:	7942                	ld	s2,48(sp)
    80004bc6:	79a2                	ld	s3,40(sp)
    80004bc8:	7a02                	ld	s4,32(sp)
    80004bca:	6ae2                	ld	s5,24(sp)
    80004bcc:	6b42                	ld	s6,16(sp)
    80004bce:	6ba2                	ld	s7,8(sp)
    80004bd0:	6c02                	ld	s8,0(sp)
    80004bd2:	6161                	add	sp,sp,80
    80004bd4:	8082                	ret
    panic("filewrite");
    80004bd6:	00004517          	auipc	a0,0x4
    80004bda:	b1250513          	add	a0,a0,-1262 # 800086e8 <syscalls+0x298>
    80004bde:	ffffc097          	auipc	ra,0xffffc
    80004be2:	95e080e7          	jalr	-1698(ra) # 8000053c <panic>
    return -1;
    80004be6:	557d                	li	a0,-1
}
    80004be8:	8082                	ret
      return -1;
    80004bea:	557d                	li	a0,-1
    80004bec:	bfc9                	j	80004bbe <filewrite+0xf8>
    80004bee:	557d                	li	a0,-1
    80004bf0:	b7f9                	j	80004bbe <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004bf2:	557d                	li	a0,-1
    80004bf4:	b7e9                	j	80004bbe <filewrite+0xf8>

0000000080004bf6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004bf6:	7179                	add	sp,sp,-48
    80004bf8:	f406                	sd	ra,40(sp)
    80004bfa:	f022                	sd	s0,32(sp)
    80004bfc:	ec26                	sd	s1,24(sp)
    80004bfe:	e84a                	sd	s2,16(sp)
    80004c00:	e44e                	sd	s3,8(sp)
    80004c02:	e052                	sd	s4,0(sp)
    80004c04:	1800                	add	s0,sp,48
    80004c06:	84aa                	mv	s1,a0
    80004c08:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c0a:	0005b023          	sd	zero,0(a1)
    80004c0e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c12:	00000097          	auipc	ra,0x0
    80004c16:	bfc080e7          	jalr	-1028(ra) # 8000480e <filealloc>
    80004c1a:	e088                	sd	a0,0(s1)
    80004c1c:	c551                	beqz	a0,80004ca8 <pipealloc+0xb2>
    80004c1e:	00000097          	auipc	ra,0x0
    80004c22:	bf0080e7          	jalr	-1040(ra) # 8000480e <filealloc>
    80004c26:	00aa3023          	sd	a0,0(s4)
    80004c2a:	c92d                	beqz	a0,80004c9c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004c2c:	ffffc097          	auipc	ra,0xffffc
    80004c30:	eb6080e7          	jalr	-330(ra) # 80000ae2 <kalloc>
    80004c34:	892a                	mv	s2,a0
    80004c36:	c125                	beqz	a0,80004c96 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004c38:	4985                	li	s3,1
    80004c3a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004c3e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004c42:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004c46:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c4a:	00004597          	auipc	a1,0x4
    80004c4e:	aae58593          	add	a1,a1,-1362 # 800086f8 <syscalls+0x2a8>
    80004c52:	ffffc097          	auipc	ra,0xffffc
    80004c56:	ef0080e7          	jalr	-272(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004c5a:	609c                	ld	a5,0(s1)
    80004c5c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c60:	609c                	ld	a5,0(s1)
    80004c62:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c66:	609c                	ld	a5,0(s1)
    80004c68:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c6c:	609c                	ld	a5,0(s1)
    80004c6e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c72:	000a3783          	ld	a5,0(s4)
    80004c76:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c7a:	000a3783          	ld	a5,0(s4)
    80004c7e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c82:	000a3783          	ld	a5,0(s4)
    80004c86:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c8a:	000a3783          	ld	a5,0(s4)
    80004c8e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004c92:	4501                	li	a0,0
    80004c94:	a025                	j	80004cbc <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004c96:	6088                	ld	a0,0(s1)
    80004c98:	e501                	bnez	a0,80004ca0 <pipealloc+0xaa>
    80004c9a:	a039                	j	80004ca8 <pipealloc+0xb2>
    80004c9c:	6088                	ld	a0,0(s1)
    80004c9e:	c51d                	beqz	a0,80004ccc <pipealloc+0xd6>
    fileclose(*f0);
    80004ca0:	00000097          	auipc	ra,0x0
    80004ca4:	c2a080e7          	jalr	-982(ra) # 800048ca <fileclose>
  if(*f1)
    80004ca8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004cac:	557d                	li	a0,-1
  if(*f1)
    80004cae:	c799                	beqz	a5,80004cbc <pipealloc+0xc6>
    fileclose(*f1);
    80004cb0:	853e                	mv	a0,a5
    80004cb2:	00000097          	auipc	ra,0x0
    80004cb6:	c18080e7          	jalr	-1000(ra) # 800048ca <fileclose>
  return -1;
    80004cba:	557d                	li	a0,-1
}
    80004cbc:	70a2                	ld	ra,40(sp)
    80004cbe:	7402                	ld	s0,32(sp)
    80004cc0:	64e2                	ld	s1,24(sp)
    80004cc2:	6942                	ld	s2,16(sp)
    80004cc4:	69a2                	ld	s3,8(sp)
    80004cc6:	6a02                	ld	s4,0(sp)
    80004cc8:	6145                	add	sp,sp,48
    80004cca:	8082                	ret
  return -1;
    80004ccc:	557d                	li	a0,-1
    80004cce:	b7fd                	j	80004cbc <pipealloc+0xc6>

0000000080004cd0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004cd0:	1101                	add	sp,sp,-32
    80004cd2:	ec06                	sd	ra,24(sp)
    80004cd4:	e822                	sd	s0,16(sp)
    80004cd6:	e426                	sd	s1,8(sp)
    80004cd8:	e04a                	sd	s2,0(sp)
    80004cda:	1000                	add	s0,sp,32
    80004cdc:	84aa                	mv	s1,a0
    80004cde:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ce0:	ffffc097          	auipc	ra,0xffffc
    80004ce4:	ef2080e7          	jalr	-270(ra) # 80000bd2 <acquire>
  if(writable){
    80004ce8:	02090d63          	beqz	s2,80004d22 <pipeclose+0x52>
    pi->writeopen = 0;
    80004cec:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004cf0:	21848513          	add	a0,s1,536
    80004cf4:	ffffd097          	auipc	ra,0xffffd
    80004cf8:	464080e7          	jalr	1124(ra) # 80002158 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004cfc:	2204b783          	ld	a5,544(s1)
    80004d00:	eb95                	bnez	a5,80004d34 <pipeclose+0x64>
    release(&pi->lock);
    80004d02:	8526                	mv	a0,s1
    80004d04:	ffffc097          	auipc	ra,0xffffc
    80004d08:	f82080e7          	jalr	-126(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004d0c:	8526                	mv	a0,s1
    80004d0e:	ffffc097          	auipc	ra,0xffffc
    80004d12:	cd6080e7          	jalr	-810(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004d16:	60e2                	ld	ra,24(sp)
    80004d18:	6442                	ld	s0,16(sp)
    80004d1a:	64a2                	ld	s1,8(sp)
    80004d1c:	6902                	ld	s2,0(sp)
    80004d1e:	6105                	add	sp,sp,32
    80004d20:	8082                	ret
    pi->readopen = 0;
    80004d22:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004d26:	21c48513          	add	a0,s1,540
    80004d2a:	ffffd097          	auipc	ra,0xffffd
    80004d2e:	42e080e7          	jalr	1070(ra) # 80002158 <wakeup>
    80004d32:	b7e9                	j	80004cfc <pipeclose+0x2c>
    release(&pi->lock);
    80004d34:	8526                	mv	a0,s1
    80004d36:	ffffc097          	auipc	ra,0xffffc
    80004d3a:	f50080e7          	jalr	-176(ra) # 80000c86 <release>
}
    80004d3e:	bfe1                	j	80004d16 <pipeclose+0x46>

0000000080004d40 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d40:	711d                	add	sp,sp,-96
    80004d42:	ec86                	sd	ra,88(sp)
    80004d44:	e8a2                	sd	s0,80(sp)
    80004d46:	e4a6                	sd	s1,72(sp)
    80004d48:	e0ca                	sd	s2,64(sp)
    80004d4a:	fc4e                	sd	s3,56(sp)
    80004d4c:	f852                	sd	s4,48(sp)
    80004d4e:	f456                	sd	s5,40(sp)
    80004d50:	f05a                	sd	s6,32(sp)
    80004d52:	ec5e                	sd	s7,24(sp)
    80004d54:	e862                	sd	s8,16(sp)
    80004d56:	1080                	add	s0,sp,96
    80004d58:	84aa                	mv	s1,a0
    80004d5a:	8aae                	mv	s5,a1
    80004d5c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d5e:	ffffd097          	auipc	ra,0xffffd
    80004d62:	c48080e7          	jalr	-952(ra) # 800019a6 <myproc>
    80004d66:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d68:	8526                	mv	a0,s1
    80004d6a:	ffffc097          	auipc	ra,0xffffc
    80004d6e:	e68080e7          	jalr	-408(ra) # 80000bd2 <acquire>
  while(i < n){
    80004d72:	0b405663          	blez	s4,80004e1e <pipewrite+0xde>
  int i = 0;
    80004d76:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d78:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d7a:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d7e:	21c48b93          	add	s7,s1,540
    80004d82:	a089                	j	80004dc4 <pipewrite+0x84>
      release(&pi->lock);
    80004d84:	8526                	mv	a0,s1
    80004d86:	ffffc097          	auipc	ra,0xffffc
    80004d8a:	f00080e7          	jalr	-256(ra) # 80000c86 <release>
      return -1;
    80004d8e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d90:	854a                	mv	a0,s2
    80004d92:	60e6                	ld	ra,88(sp)
    80004d94:	6446                	ld	s0,80(sp)
    80004d96:	64a6                	ld	s1,72(sp)
    80004d98:	6906                	ld	s2,64(sp)
    80004d9a:	79e2                	ld	s3,56(sp)
    80004d9c:	7a42                	ld	s4,48(sp)
    80004d9e:	7aa2                	ld	s5,40(sp)
    80004da0:	7b02                	ld	s6,32(sp)
    80004da2:	6be2                	ld	s7,24(sp)
    80004da4:	6c42                	ld	s8,16(sp)
    80004da6:	6125                	add	sp,sp,96
    80004da8:	8082                	ret
      wakeup(&pi->nread);
    80004daa:	8562                	mv	a0,s8
    80004dac:	ffffd097          	auipc	ra,0xffffd
    80004db0:	3ac080e7          	jalr	940(ra) # 80002158 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004db4:	85a6                	mv	a1,s1
    80004db6:	855e                	mv	a0,s7
    80004db8:	ffffd097          	auipc	ra,0xffffd
    80004dbc:	33c080e7          	jalr	828(ra) # 800020f4 <sleep>
  while(i < n){
    80004dc0:	07495063          	bge	s2,s4,80004e20 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004dc4:	2204a783          	lw	a5,544(s1)
    80004dc8:	dfd5                	beqz	a5,80004d84 <pipewrite+0x44>
    80004dca:	854e                	mv	a0,s3
    80004dcc:	ffffd097          	auipc	ra,0xffffd
    80004dd0:	5dc080e7          	jalr	1500(ra) # 800023a8 <killed>
    80004dd4:	f945                	bnez	a0,80004d84 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004dd6:	2184a783          	lw	a5,536(s1)
    80004dda:	21c4a703          	lw	a4,540(s1)
    80004dde:	2007879b          	addw	a5,a5,512
    80004de2:	fcf704e3          	beq	a4,a5,80004daa <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004de6:	4685                	li	a3,1
    80004de8:	01590633          	add	a2,s2,s5
    80004dec:	faf40593          	add	a1,s0,-81
    80004df0:	0509b503          	ld	a0,80(s3)
    80004df4:	ffffd097          	auipc	ra,0xffffd
    80004df8:	8fe080e7          	jalr	-1794(ra) # 800016f2 <copyin>
    80004dfc:	03650263          	beq	a0,s6,80004e20 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004e00:	21c4a783          	lw	a5,540(s1)
    80004e04:	0017871b          	addw	a4,a5,1
    80004e08:	20e4ae23          	sw	a4,540(s1)
    80004e0c:	1ff7f793          	and	a5,a5,511
    80004e10:	97a6                	add	a5,a5,s1
    80004e12:	faf44703          	lbu	a4,-81(s0)
    80004e16:	00e78c23          	sb	a4,24(a5)
      i++;
    80004e1a:	2905                	addw	s2,s2,1
    80004e1c:	b755                	j	80004dc0 <pipewrite+0x80>
  int i = 0;
    80004e1e:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004e20:	21848513          	add	a0,s1,536
    80004e24:	ffffd097          	auipc	ra,0xffffd
    80004e28:	334080e7          	jalr	820(ra) # 80002158 <wakeup>
  release(&pi->lock);
    80004e2c:	8526                	mv	a0,s1
    80004e2e:	ffffc097          	auipc	ra,0xffffc
    80004e32:	e58080e7          	jalr	-424(ra) # 80000c86 <release>
  return i;
    80004e36:	bfa9                	j	80004d90 <pipewrite+0x50>

0000000080004e38 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e38:	715d                	add	sp,sp,-80
    80004e3a:	e486                	sd	ra,72(sp)
    80004e3c:	e0a2                	sd	s0,64(sp)
    80004e3e:	fc26                	sd	s1,56(sp)
    80004e40:	f84a                	sd	s2,48(sp)
    80004e42:	f44e                	sd	s3,40(sp)
    80004e44:	f052                	sd	s4,32(sp)
    80004e46:	ec56                	sd	s5,24(sp)
    80004e48:	e85a                	sd	s6,16(sp)
    80004e4a:	0880                	add	s0,sp,80
    80004e4c:	84aa                	mv	s1,a0
    80004e4e:	892e                	mv	s2,a1
    80004e50:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e52:	ffffd097          	auipc	ra,0xffffd
    80004e56:	b54080e7          	jalr	-1196(ra) # 800019a6 <myproc>
    80004e5a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e5c:	8526                	mv	a0,s1
    80004e5e:	ffffc097          	auipc	ra,0xffffc
    80004e62:	d74080e7          	jalr	-652(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e66:	2184a703          	lw	a4,536(s1)
    80004e6a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e6e:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e72:	02f71763          	bne	a4,a5,80004ea0 <piperead+0x68>
    80004e76:	2244a783          	lw	a5,548(s1)
    80004e7a:	c39d                	beqz	a5,80004ea0 <piperead+0x68>
    if(killed(pr)){
    80004e7c:	8552                	mv	a0,s4
    80004e7e:	ffffd097          	auipc	ra,0xffffd
    80004e82:	52a080e7          	jalr	1322(ra) # 800023a8 <killed>
    80004e86:	e949                	bnez	a0,80004f18 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e88:	85a6                	mv	a1,s1
    80004e8a:	854e                	mv	a0,s3
    80004e8c:	ffffd097          	auipc	ra,0xffffd
    80004e90:	268080e7          	jalr	616(ra) # 800020f4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e94:	2184a703          	lw	a4,536(s1)
    80004e98:	21c4a783          	lw	a5,540(s1)
    80004e9c:	fcf70de3          	beq	a4,a5,80004e76 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ea0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ea2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ea4:	05505463          	blez	s5,80004eec <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004ea8:	2184a783          	lw	a5,536(s1)
    80004eac:	21c4a703          	lw	a4,540(s1)
    80004eb0:	02f70e63          	beq	a4,a5,80004eec <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004eb4:	0017871b          	addw	a4,a5,1
    80004eb8:	20e4ac23          	sw	a4,536(s1)
    80004ebc:	1ff7f793          	and	a5,a5,511
    80004ec0:	97a6                	add	a5,a5,s1
    80004ec2:	0187c783          	lbu	a5,24(a5)
    80004ec6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004eca:	4685                	li	a3,1
    80004ecc:	fbf40613          	add	a2,s0,-65
    80004ed0:	85ca                	mv	a1,s2
    80004ed2:	050a3503          	ld	a0,80(s4)
    80004ed6:	ffffc097          	auipc	ra,0xffffc
    80004eda:	790080e7          	jalr	1936(ra) # 80001666 <copyout>
    80004ede:	01650763          	beq	a0,s6,80004eec <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ee2:	2985                	addw	s3,s3,1
    80004ee4:	0905                	add	s2,s2,1
    80004ee6:	fd3a91e3          	bne	s5,s3,80004ea8 <piperead+0x70>
    80004eea:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004eec:	21c48513          	add	a0,s1,540
    80004ef0:	ffffd097          	auipc	ra,0xffffd
    80004ef4:	268080e7          	jalr	616(ra) # 80002158 <wakeup>
  release(&pi->lock);
    80004ef8:	8526                	mv	a0,s1
    80004efa:	ffffc097          	auipc	ra,0xffffc
    80004efe:	d8c080e7          	jalr	-628(ra) # 80000c86 <release>
  return i;
}
    80004f02:	854e                	mv	a0,s3
    80004f04:	60a6                	ld	ra,72(sp)
    80004f06:	6406                	ld	s0,64(sp)
    80004f08:	74e2                	ld	s1,56(sp)
    80004f0a:	7942                	ld	s2,48(sp)
    80004f0c:	79a2                	ld	s3,40(sp)
    80004f0e:	7a02                	ld	s4,32(sp)
    80004f10:	6ae2                	ld	s5,24(sp)
    80004f12:	6b42                	ld	s6,16(sp)
    80004f14:	6161                	add	sp,sp,80
    80004f16:	8082                	ret
      release(&pi->lock);
    80004f18:	8526                	mv	a0,s1
    80004f1a:	ffffc097          	auipc	ra,0xffffc
    80004f1e:	d6c080e7          	jalr	-660(ra) # 80000c86 <release>
      return -1;
    80004f22:	59fd                	li	s3,-1
    80004f24:	bff9                	j	80004f02 <piperead+0xca>

0000000080004f26 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004f26:	1141                	add	sp,sp,-16
    80004f28:	e422                	sd	s0,8(sp)
    80004f2a:	0800                	add	s0,sp,16
    80004f2c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004f2e:	8905                	and	a0,a0,1
    80004f30:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004f32:	8b89                	and	a5,a5,2
    80004f34:	c399                	beqz	a5,80004f3a <flags2perm+0x14>
      perm |= PTE_W;
    80004f36:	00456513          	or	a0,a0,4
    return perm;
}
    80004f3a:	6422                	ld	s0,8(sp)
    80004f3c:	0141                	add	sp,sp,16
    80004f3e:	8082                	ret

0000000080004f40 <exec>:

int
exec(char *path, char **argv)
{
    80004f40:	df010113          	add	sp,sp,-528
    80004f44:	20113423          	sd	ra,520(sp)
    80004f48:	20813023          	sd	s0,512(sp)
    80004f4c:	ffa6                	sd	s1,504(sp)
    80004f4e:	fbca                	sd	s2,496(sp)
    80004f50:	f7ce                	sd	s3,488(sp)
    80004f52:	f3d2                	sd	s4,480(sp)
    80004f54:	efd6                	sd	s5,472(sp)
    80004f56:	ebda                	sd	s6,464(sp)
    80004f58:	e7de                	sd	s7,456(sp)
    80004f5a:	e3e2                	sd	s8,448(sp)
    80004f5c:	ff66                	sd	s9,440(sp)
    80004f5e:	fb6a                	sd	s10,432(sp)
    80004f60:	f76e                	sd	s11,424(sp)
    80004f62:	0c00                	add	s0,sp,528
    80004f64:	892a                	mv	s2,a0
    80004f66:	dea43c23          	sd	a0,-520(s0)
    80004f6a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f6e:	ffffd097          	auipc	ra,0xffffd
    80004f72:	a38080e7          	jalr	-1480(ra) # 800019a6 <myproc>
    80004f76:	84aa                	mv	s1,a0

  begin_op();
    80004f78:	fffff097          	auipc	ra,0xfffff
    80004f7c:	476080e7          	jalr	1142(ra) # 800043ee <begin_op>

  if((ip = namei(path)) == 0){
    80004f80:	854a                	mv	a0,s2
    80004f82:	fffff097          	auipc	ra,0xfffff
    80004f86:	26c080e7          	jalr	620(ra) # 800041ee <namei>
    80004f8a:	c92d                	beqz	a0,80004ffc <exec+0xbc>
    80004f8c:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f8e:	fffff097          	auipc	ra,0xfffff
    80004f92:	aba080e7          	jalr	-1350(ra) # 80003a48 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f96:	04000713          	li	a4,64
    80004f9a:	4681                	li	a3,0
    80004f9c:	e5040613          	add	a2,s0,-432
    80004fa0:	4581                	li	a1,0
    80004fa2:	8552                	mv	a0,s4
    80004fa4:	fffff097          	auipc	ra,0xfffff
    80004fa8:	d58080e7          	jalr	-680(ra) # 80003cfc <readi>
    80004fac:	04000793          	li	a5,64
    80004fb0:	00f51a63          	bne	a0,a5,80004fc4 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004fb4:	e5042703          	lw	a4,-432(s0)
    80004fb8:	464c47b7          	lui	a5,0x464c4
    80004fbc:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004fc0:	04f70463          	beq	a4,a5,80005008 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004fc4:	8552                	mv	a0,s4
    80004fc6:	fffff097          	auipc	ra,0xfffff
    80004fca:	ce4080e7          	jalr	-796(ra) # 80003caa <iunlockput>
    end_op();
    80004fce:	fffff097          	auipc	ra,0xfffff
    80004fd2:	49a080e7          	jalr	1178(ra) # 80004468 <end_op>
  }
  return -1;
    80004fd6:	557d                	li	a0,-1
}
    80004fd8:	20813083          	ld	ra,520(sp)
    80004fdc:	20013403          	ld	s0,512(sp)
    80004fe0:	74fe                	ld	s1,504(sp)
    80004fe2:	795e                	ld	s2,496(sp)
    80004fe4:	79be                	ld	s3,488(sp)
    80004fe6:	7a1e                	ld	s4,480(sp)
    80004fe8:	6afe                	ld	s5,472(sp)
    80004fea:	6b5e                	ld	s6,464(sp)
    80004fec:	6bbe                	ld	s7,456(sp)
    80004fee:	6c1e                	ld	s8,448(sp)
    80004ff0:	7cfa                	ld	s9,440(sp)
    80004ff2:	7d5a                	ld	s10,432(sp)
    80004ff4:	7dba                	ld	s11,424(sp)
    80004ff6:	21010113          	add	sp,sp,528
    80004ffa:	8082                	ret
    end_op();
    80004ffc:	fffff097          	auipc	ra,0xfffff
    80005000:	46c080e7          	jalr	1132(ra) # 80004468 <end_op>
    return -1;
    80005004:	557d                	li	a0,-1
    80005006:	bfc9                	j	80004fd8 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80005008:	8526                	mv	a0,s1
    8000500a:	ffffd097          	auipc	ra,0xffffd
    8000500e:	a60080e7          	jalr	-1440(ra) # 80001a6a <proc_pagetable>
    80005012:	8b2a                	mv	s6,a0
    80005014:	d945                	beqz	a0,80004fc4 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005016:	e7042d03          	lw	s10,-400(s0)
    8000501a:	e8845783          	lhu	a5,-376(s0)
    8000501e:	10078463          	beqz	a5,80005126 <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005022:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005024:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80005026:	6c85                	lui	s9,0x1
    80005028:	fffc8793          	add	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000502c:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80005030:	6a85                	lui	s5,0x1
    80005032:	a0b5                	j	8000509e <exec+0x15e>
      panic("loadseg: address should exist");
    80005034:	00003517          	auipc	a0,0x3
    80005038:	6cc50513          	add	a0,a0,1740 # 80008700 <syscalls+0x2b0>
    8000503c:	ffffb097          	auipc	ra,0xffffb
    80005040:	500080e7          	jalr	1280(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80005044:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005046:	8726                	mv	a4,s1
    80005048:	012c06bb          	addw	a3,s8,s2
    8000504c:	4581                	li	a1,0
    8000504e:	8552                	mv	a0,s4
    80005050:	fffff097          	auipc	ra,0xfffff
    80005054:	cac080e7          	jalr	-852(ra) # 80003cfc <readi>
    80005058:	2501                	sext.w	a0,a0
    8000505a:	24a49863          	bne	s1,a0,800052aa <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    8000505e:	012a893b          	addw	s2,s5,s2
    80005062:	03397563          	bgeu	s2,s3,8000508c <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80005066:	02091593          	sll	a1,s2,0x20
    8000506a:	9181                	srl	a1,a1,0x20
    8000506c:	95de                	add	a1,a1,s7
    8000506e:	855a                	mv	a0,s6
    80005070:	ffffc097          	auipc	ra,0xffffc
    80005074:	fe6080e7          	jalr	-26(ra) # 80001056 <walkaddr>
    80005078:	862a                	mv	a2,a0
    if(pa == 0)
    8000507a:	dd4d                	beqz	a0,80005034 <exec+0xf4>
    if(sz - i < PGSIZE)
    8000507c:	412984bb          	subw	s1,s3,s2
    80005080:	0004879b          	sext.w	a5,s1
    80005084:	fcfcf0e3          	bgeu	s9,a5,80005044 <exec+0x104>
    80005088:	84d6                	mv	s1,s5
    8000508a:	bf6d                	j	80005044 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000508c:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005090:	2d85                	addw	s11,s11,1
    80005092:	038d0d1b          	addw	s10,s10,56
    80005096:	e8845783          	lhu	a5,-376(s0)
    8000509a:	08fdd763          	bge	s11,a5,80005128 <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000509e:	2d01                	sext.w	s10,s10
    800050a0:	03800713          	li	a4,56
    800050a4:	86ea                	mv	a3,s10
    800050a6:	e1840613          	add	a2,s0,-488
    800050aa:	4581                	li	a1,0
    800050ac:	8552                	mv	a0,s4
    800050ae:	fffff097          	auipc	ra,0xfffff
    800050b2:	c4e080e7          	jalr	-946(ra) # 80003cfc <readi>
    800050b6:	03800793          	li	a5,56
    800050ba:	1ef51663          	bne	a0,a5,800052a6 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    800050be:	e1842783          	lw	a5,-488(s0)
    800050c2:	4705                	li	a4,1
    800050c4:	fce796e3          	bne	a5,a4,80005090 <exec+0x150>
    if(ph.memsz < ph.filesz)
    800050c8:	e4043483          	ld	s1,-448(s0)
    800050cc:	e3843783          	ld	a5,-456(s0)
    800050d0:	1ef4e863          	bltu	s1,a5,800052c0 <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800050d4:	e2843783          	ld	a5,-472(s0)
    800050d8:	94be                	add	s1,s1,a5
    800050da:	1ef4e663          	bltu	s1,a5,800052c6 <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    800050de:	df043703          	ld	a4,-528(s0)
    800050e2:	8ff9                	and	a5,a5,a4
    800050e4:	1e079463          	bnez	a5,800052cc <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800050e8:	e1c42503          	lw	a0,-484(s0)
    800050ec:	00000097          	auipc	ra,0x0
    800050f0:	e3a080e7          	jalr	-454(ra) # 80004f26 <flags2perm>
    800050f4:	86aa                	mv	a3,a0
    800050f6:	8626                	mv	a2,s1
    800050f8:	85ca                	mv	a1,s2
    800050fa:	855a                	mv	a0,s6
    800050fc:	ffffc097          	auipc	ra,0xffffc
    80005100:	30e080e7          	jalr	782(ra) # 8000140a <uvmalloc>
    80005104:	e0a43423          	sd	a0,-504(s0)
    80005108:	1c050563          	beqz	a0,800052d2 <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000510c:	e2843b83          	ld	s7,-472(s0)
    80005110:	e2042c03          	lw	s8,-480(s0)
    80005114:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005118:	00098463          	beqz	s3,80005120 <exec+0x1e0>
    8000511c:	4901                	li	s2,0
    8000511e:	b7a1                	j	80005066 <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005120:	e0843903          	ld	s2,-504(s0)
    80005124:	b7b5                	j	80005090 <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005126:	4901                	li	s2,0
  iunlockput(ip);
    80005128:	8552                	mv	a0,s4
    8000512a:	fffff097          	auipc	ra,0xfffff
    8000512e:	b80080e7          	jalr	-1152(ra) # 80003caa <iunlockput>
  end_op();
    80005132:	fffff097          	auipc	ra,0xfffff
    80005136:	336080e7          	jalr	822(ra) # 80004468 <end_op>
  p = myproc();
    8000513a:	ffffd097          	auipc	ra,0xffffd
    8000513e:	86c080e7          	jalr	-1940(ra) # 800019a6 <myproc>
    80005142:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005144:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005148:	6985                	lui	s3,0x1
    8000514a:	19fd                	add	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000514c:	99ca                	add	s3,s3,s2
    8000514e:	77fd                	lui	a5,0xfffff
    80005150:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005154:	4691                	li	a3,4
    80005156:	6609                	lui	a2,0x2
    80005158:	964e                	add	a2,a2,s3
    8000515a:	85ce                	mv	a1,s3
    8000515c:	855a                	mv	a0,s6
    8000515e:	ffffc097          	auipc	ra,0xffffc
    80005162:	2ac080e7          	jalr	684(ra) # 8000140a <uvmalloc>
    80005166:	892a                	mv	s2,a0
    80005168:	e0a43423          	sd	a0,-504(s0)
    8000516c:	e509                	bnez	a0,80005176 <exec+0x236>
  if(pagetable)
    8000516e:	e1343423          	sd	s3,-504(s0)
    80005172:	4a01                	li	s4,0
    80005174:	aa1d                	j	800052aa <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005176:	75f9                	lui	a1,0xffffe
    80005178:	95aa                	add	a1,a1,a0
    8000517a:	855a                	mv	a0,s6
    8000517c:	ffffc097          	auipc	ra,0xffffc
    80005180:	4b8080e7          	jalr	1208(ra) # 80001634 <uvmclear>
  stackbase = sp - PGSIZE;
    80005184:	7bfd                	lui	s7,0xfffff
    80005186:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80005188:	e0043783          	ld	a5,-512(s0)
    8000518c:	6388                	ld	a0,0(a5)
    8000518e:	c52d                	beqz	a0,800051f8 <exec+0x2b8>
    80005190:	e9040993          	add	s3,s0,-368
    80005194:	f9040c13          	add	s8,s0,-112
    80005198:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000519a:	ffffc097          	auipc	ra,0xffffc
    8000519e:	cae080e7          	jalr	-850(ra) # 80000e48 <strlen>
    800051a2:	0015079b          	addw	a5,a0,1
    800051a6:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800051aa:	ff07f913          	and	s2,a5,-16
    if(sp < stackbase)
    800051ae:	13796563          	bltu	s2,s7,800052d8 <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800051b2:	e0043d03          	ld	s10,-512(s0)
    800051b6:	000d3a03          	ld	s4,0(s10)
    800051ba:	8552                	mv	a0,s4
    800051bc:	ffffc097          	auipc	ra,0xffffc
    800051c0:	c8c080e7          	jalr	-884(ra) # 80000e48 <strlen>
    800051c4:	0015069b          	addw	a3,a0,1
    800051c8:	8652                	mv	a2,s4
    800051ca:	85ca                	mv	a1,s2
    800051cc:	855a                	mv	a0,s6
    800051ce:	ffffc097          	auipc	ra,0xffffc
    800051d2:	498080e7          	jalr	1176(ra) # 80001666 <copyout>
    800051d6:	10054363          	bltz	a0,800052dc <exec+0x39c>
    ustack[argc] = sp;
    800051da:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800051de:	0485                	add	s1,s1,1
    800051e0:	008d0793          	add	a5,s10,8
    800051e4:	e0f43023          	sd	a5,-512(s0)
    800051e8:	008d3503          	ld	a0,8(s10)
    800051ec:	c909                	beqz	a0,800051fe <exec+0x2be>
    if(argc >= MAXARG)
    800051ee:	09a1                	add	s3,s3,8
    800051f0:	fb8995e3          	bne	s3,s8,8000519a <exec+0x25a>
  ip = 0;
    800051f4:	4a01                	li	s4,0
    800051f6:	a855                	j	800052aa <exec+0x36a>
  sp = sz;
    800051f8:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800051fc:	4481                	li	s1,0
  ustack[argc] = 0;
    800051fe:	00349793          	sll	a5,s1,0x3
    80005202:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdc5e8>
    80005206:	97a2                	add	a5,a5,s0
    80005208:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000520c:	00148693          	add	a3,s1,1
    80005210:	068e                	sll	a3,a3,0x3
    80005212:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005216:	ff097913          	and	s2,s2,-16
  sz = sz1;
    8000521a:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    8000521e:	f57968e3          	bltu	s2,s7,8000516e <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005222:	e9040613          	add	a2,s0,-368
    80005226:	85ca                	mv	a1,s2
    80005228:	855a                	mv	a0,s6
    8000522a:	ffffc097          	auipc	ra,0xffffc
    8000522e:	43c080e7          	jalr	1084(ra) # 80001666 <copyout>
    80005232:	0a054763          	bltz	a0,800052e0 <exec+0x3a0>
  p->trapframe->a1 = sp;
    80005236:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    8000523a:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000523e:	df843783          	ld	a5,-520(s0)
    80005242:	0007c703          	lbu	a4,0(a5)
    80005246:	cf11                	beqz	a4,80005262 <exec+0x322>
    80005248:	0785                	add	a5,a5,1
    if(*s == '/')
    8000524a:	02f00693          	li	a3,47
    8000524e:	a039                	j	8000525c <exec+0x31c>
      last = s+1;
    80005250:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005254:	0785                	add	a5,a5,1
    80005256:	fff7c703          	lbu	a4,-1(a5)
    8000525a:	c701                	beqz	a4,80005262 <exec+0x322>
    if(*s == '/')
    8000525c:	fed71ce3          	bne	a4,a3,80005254 <exec+0x314>
    80005260:	bfc5                	j	80005250 <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    80005262:	4641                	li	a2,16
    80005264:	df843583          	ld	a1,-520(s0)
    80005268:	158a8513          	add	a0,s5,344
    8000526c:	ffffc097          	auipc	ra,0xffffc
    80005270:	baa080e7          	jalr	-1110(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80005274:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80005278:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    8000527c:	e0843783          	ld	a5,-504(s0)
    80005280:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005284:	058ab783          	ld	a5,88(s5)
    80005288:	e6843703          	ld	a4,-408(s0)
    8000528c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000528e:	058ab783          	ld	a5,88(s5)
    80005292:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005296:	85e6                	mv	a1,s9
    80005298:	ffffd097          	auipc	ra,0xffffd
    8000529c:	86e080e7          	jalr	-1938(ra) # 80001b06 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800052a0:	0004851b          	sext.w	a0,s1
    800052a4:	bb15                	j	80004fd8 <exec+0x98>
    800052a6:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    800052aa:	e0843583          	ld	a1,-504(s0)
    800052ae:	855a                	mv	a0,s6
    800052b0:	ffffd097          	auipc	ra,0xffffd
    800052b4:	856080e7          	jalr	-1962(ra) # 80001b06 <proc_freepagetable>
  return -1;
    800052b8:	557d                	li	a0,-1
  if(ip){
    800052ba:	d00a0fe3          	beqz	s4,80004fd8 <exec+0x98>
    800052be:	b319                	j	80004fc4 <exec+0x84>
    800052c0:	e1243423          	sd	s2,-504(s0)
    800052c4:	b7dd                	j	800052aa <exec+0x36a>
    800052c6:	e1243423          	sd	s2,-504(s0)
    800052ca:	b7c5                	j	800052aa <exec+0x36a>
    800052cc:	e1243423          	sd	s2,-504(s0)
    800052d0:	bfe9                	j	800052aa <exec+0x36a>
    800052d2:	e1243423          	sd	s2,-504(s0)
    800052d6:	bfd1                	j	800052aa <exec+0x36a>
  ip = 0;
    800052d8:	4a01                	li	s4,0
    800052da:	bfc1                	j	800052aa <exec+0x36a>
    800052dc:	4a01                	li	s4,0
  if(pagetable)
    800052de:	b7f1                	j	800052aa <exec+0x36a>
  sz = sz1;
    800052e0:	e0843983          	ld	s3,-504(s0)
    800052e4:	b569                	j	8000516e <exec+0x22e>

00000000800052e6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800052e6:	7179                	add	sp,sp,-48
    800052e8:	f406                	sd	ra,40(sp)
    800052ea:	f022                	sd	s0,32(sp)
    800052ec:	ec26                	sd	s1,24(sp)
    800052ee:	e84a                	sd	s2,16(sp)
    800052f0:	1800                	add	s0,sp,48
    800052f2:	892e                	mv	s2,a1
    800052f4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800052f6:	fdc40593          	add	a1,s0,-36
    800052fa:	ffffe097          	auipc	ra,0xffffe
    800052fe:	a74080e7          	jalr	-1420(ra) # 80002d6e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005302:	fdc42703          	lw	a4,-36(s0)
    80005306:	47bd                	li	a5,15
    80005308:	02e7eb63          	bltu	a5,a4,8000533e <argfd+0x58>
    8000530c:	ffffc097          	auipc	ra,0xffffc
    80005310:	69a080e7          	jalr	1690(ra) # 800019a6 <myproc>
    80005314:	fdc42703          	lw	a4,-36(s0)
    80005318:	01a70793          	add	a5,a4,26
    8000531c:	078e                	sll	a5,a5,0x3
    8000531e:	953e                	add	a0,a0,a5
    80005320:	611c                	ld	a5,0(a0)
    80005322:	c385                	beqz	a5,80005342 <argfd+0x5c>
    return -1;
  if(pfd)
    80005324:	00090463          	beqz	s2,8000532c <argfd+0x46>
    *pfd = fd;
    80005328:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000532c:	4501                	li	a0,0
  if(pf)
    8000532e:	c091                	beqz	s1,80005332 <argfd+0x4c>
    *pf = f;
    80005330:	e09c                	sd	a5,0(s1)
}
    80005332:	70a2                	ld	ra,40(sp)
    80005334:	7402                	ld	s0,32(sp)
    80005336:	64e2                	ld	s1,24(sp)
    80005338:	6942                	ld	s2,16(sp)
    8000533a:	6145                	add	sp,sp,48
    8000533c:	8082                	ret
    return -1;
    8000533e:	557d                	li	a0,-1
    80005340:	bfcd                	j	80005332 <argfd+0x4c>
    80005342:	557d                	li	a0,-1
    80005344:	b7fd                	j	80005332 <argfd+0x4c>

0000000080005346 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005346:	1101                	add	sp,sp,-32
    80005348:	ec06                	sd	ra,24(sp)
    8000534a:	e822                	sd	s0,16(sp)
    8000534c:	e426                	sd	s1,8(sp)
    8000534e:	1000                	add	s0,sp,32
    80005350:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005352:	ffffc097          	auipc	ra,0xffffc
    80005356:	654080e7          	jalr	1620(ra) # 800019a6 <myproc>
    8000535a:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000535c:	0d050793          	add	a5,a0,208
    80005360:	4501                	li	a0,0
    80005362:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005364:	6398                	ld	a4,0(a5)
    80005366:	cb19                	beqz	a4,8000537c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005368:	2505                	addw	a0,a0,1
    8000536a:	07a1                	add	a5,a5,8
    8000536c:	fed51ce3          	bne	a0,a3,80005364 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005370:	557d                	li	a0,-1
}
    80005372:	60e2                	ld	ra,24(sp)
    80005374:	6442                	ld	s0,16(sp)
    80005376:	64a2                	ld	s1,8(sp)
    80005378:	6105                	add	sp,sp,32
    8000537a:	8082                	ret
      p->ofile[fd] = f;
    8000537c:	01a50793          	add	a5,a0,26
    80005380:	078e                	sll	a5,a5,0x3
    80005382:	963e                	add	a2,a2,a5
    80005384:	e204                	sd	s1,0(a2)
      return fd;
    80005386:	b7f5                	j	80005372 <fdalloc+0x2c>

0000000080005388 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005388:	715d                	add	sp,sp,-80
    8000538a:	e486                	sd	ra,72(sp)
    8000538c:	e0a2                	sd	s0,64(sp)
    8000538e:	fc26                	sd	s1,56(sp)
    80005390:	f84a                	sd	s2,48(sp)
    80005392:	f44e                	sd	s3,40(sp)
    80005394:	f052                	sd	s4,32(sp)
    80005396:	ec56                	sd	s5,24(sp)
    80005398:	e85a                	sd	s6,16(sp)
    8000539a:	0880                	add	s0,sp,80
    8000539c:	8b2e                	mv	s6,a1
    8000539e:	89b2                	mv	s3,a2
    800053a0:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800053a2:	fb040593          	add	a1,s0,-80
    800053a6:	fffff097          	auipc	ra,0xfffff
    800053aa:	e66080e7          	jalr	-410(ra) # 8000420c <nameiparent>
    800053ae:	84aa                	mv	s1,a0
    800053b0:	14050b63          	beqz	a0,80005506 <create+0x17e>
    return 0;

  ilock(dp);
    800053b4:	ffffe097          	auipc	ra,0xffffe
    800053b8:	694080e7          	jalr	1684(ra) # 80003a48 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800053bc:	4601                	li	a2,0
    800053be:	fb040593          	add	a1,s0,-80
    800053c2:	8526                	mv	a0,s1
    800053c4:	fffff097          	auipc	ra,0xfffff
    800053c8:	b68080e7          	jalr	-1176(ra) # 80003f2c <dirlookup>
    800053cc:	8aaa                	mv	s5,a0
    800053ce:	c921                	beqz	a0,8000541e <create+0x96>
    iunlockput(dp);
    800053d0:	8526                	mv	a0,s1
    800053d2:	fffff097          	auipc	ra,0xfffff
    800053d6:	8d8080e7          	jalr	-1832(ra) # 80003caa <iunlockput>
    ilock(ip);
    800053da:	8556                	mv	a0,s5
    800053dc:	ffffe097          	auipc	ra,0xffffe
    800053e0:	66c080e7          	jalr	1644(ra) # 80003a48 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800053e4:	4789                	li	a5,2
    800053e6:	02fb1563          	bne	s6,a5,80005410 <create+0x88>
    800053ea:	044ad783          	lhu	a5,68(s5)
    800053ee:	37f9                	addw	a5,a5,-2
    800053f0:	17c2                	sll	a5,a5,0x30
    800053f2:	93c1                	srl	a5,a5,0x30
    800053f4:	4705                	li	a4,1
    800053f6:	00f76d63          	bltu	a4,a5,80005410 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800053fa:	8556                	mv	a0,s5
    800053fc:	60a6                	ld	ra,72(sp)
    800053fe:	6406                	ld	s0,64(sp)
    80005400:	74e2                	ld	s1,56(sp)
    80005402:	7942                	ld	s2,48(sp)
    80005404:	79a2                	ld	s3,40(sp)
    80005406:	7a02                	ld	s4,32(sp)
    80005408:	6ae2                	ld	s5,24(sp)
    8000540a:	6b42                	ld	s6,16(sp)
    8000540c:	6161                	add	sp,sp,80
    8000540e:	8082                	ret
    iunlockput(ip);
    80005410:	8556                	mv	a0,s5
    80005412:	fffff097          	auipc	ra,0xfffff
    80005416:	898080e7          	jalr	-1896(ra) # 80003caa <iunlockput>
    return 0;
    8000541a:	4a81                	li	s5,0
    8000541c:	bff9                	j	800053fa <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000541e:	85da                	mv	a1,s6
    80005420:	4088                	lw	a0,0(s1)
    80005422:	ffffe097          	auipc	ra,0xffffe
    80005426:	48e080e7          	jalr	1166(ra) # 800038b0 <ialloc>
    8000542a:	8a2a                	mv	s4,a0
    8000542c:	c529                	beqz	a0,80005476 <create+0xee>
  ilock(ip);
    8000542e:	ffffe097          	auipc	ra,0xffffe
    80005432:	61a080e7          	jalr	1562(ra) # 80003a48 <ilock>
  ip->major = major;
    80005436:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000543a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000543e:	4905                	li	s2,1
    80005440:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005444:	8552                	mv	a0,s4
    80005446:	ffffe097          	auipc	ra,0xffffe
    8000544a:	536080e7          	jalr	1334(ra) # 8000397c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000544e:	032b0b63          	beq	s6,s2,80005484 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005452:	004a2603          	lw	a2,4(s4)
    80005456:	fb040593          	add	a1,s0,-80
    8000545a:	8526                	mv	a0,s1
    8000545c:	fffff097          	auipc	ra,0xfffff
    80005460:	ce0080e7          	jalr	-800(ra) # 8000413c <dirlink>
    80005464:	06054f63          	bltz	a0,800054e2 <create+0x15a>
  iunlockput(dp);
    80005468:	8526                	mv	a0,s1
    8000546a:	fffff097          	auipc	ra,0xfffff
    8000546e:	840080e7          	jalr	-1984(ra) # 80003caa <iunlockput>
  return ip;
    80005472:	8ad2                	mv	s5,s4
    80005474:	b759                	j	800053fa <create+0x72>
    iunlockput(dp);
    80005476:	8526                	mv	a0,s1
    80005478:	fffff097          	auipc	ra,0xfffff
    8000547c:	832080e7          	jalr	-1998(ra) # 80003caa <iunlockput>
    return 0;
    80005480:	8ad2                	mv	s5,s4
    80005482:	bfa5                	j	800053fa <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005484:	004a2603          	lw	a2,4(s4)
    80005488:	00003597          	auipc	a1,0x3
    8000548c:	29858593          	add	a1,a1,664 # 80008720 <syscalls+0x2d0>
    80005490:	8552                	mv	a0,s4
    80005492:	fffff097          	auipc	ra,0xfffff
    80005496:	caa080e7          	jalr	-854(ra) # 8000413c <dirlink>
    8000549a:	04054463          	bltz	a0,800054e2 <create+0x15a>
    8000549e:	40d0                	lw	a2,4(s1)
    800054a0:	00003597          	auipc	a1,0x3
    800054a4:	28858593          	add	a1,a1,648 # 80008728 <syscalls+0x2d8>
    800054a8:	8552                	mv	a0,s4
    800054aa:	fffff097          	auipc	ra,0xfffff
    800054ae:	c92080e7          	jalr	-878(ra) # 8000413c <dirlink>
    800054b2:	02054863          	bltz	a0,800054e2 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800054b6:	004a2603          	lw	a2,4(s4)
    800054ba:	fb040593          	add	a1,s0,-80
    800054be:	8526                	mv	a0,s1
    800054c0:	fffff097          	auipc	ra,0xfffff
    800054c4:	c7c080e7          	jalr	-900(ra) # 8000413c <dirlink>
    800054c8:	00054d63          	bltz	a0,800054e2 <create+0x15a>
    dp->nlink++;  // for ".."
    800054cc:	04a4d783          	lhu	a5,74(s1)
    800054d0:	2785                	addw	a5,a5,1
    800054d2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054d6:	8526                	mv	a0,s1
    800054d8:	ffffe097          	auipc	ra,0xffffe
    800054dc:	4a4080e7          	jalr	1188(ra) # 8000397c <iupdate>
    800054e0:	b761                	j	80005468 <create+0xe0>
  ip->nlink = 0;
    800054e2:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800054e6:	8552                	mv	a0,s4
    800054e8:	ffffe097          	auipc	ra,0xffffe
    800054ec:	494080e7          	jalr	1172(ra) # 8000397c <iupdate>
  iunlockput(ip);
    800054f0:	8552                	mv	a0,s4
    800054f2:	ffffe097          	auipc	ra,0xffffe
    800054f6:	7b8080e7          	jalr	1976(ra) # 80003caa <iunlockput>
  iunlockput(dp);
    800054fa:	8526                	mv	a0,s1
    800054fc:	ffffe097          	auipc	ra,0xffffe
    80005500:	7ae080e7          	jalr	1966(ra) # 80003caa <iunlockput>
  return 0;
    80005504:	bddd                	j	800053fa <create+0x72>
    return 0;
    80005506:	8aaa                	mv	s5,a0
    80005508:	bdcd                	j	800053fa <create+0x72>

000000008000550a <sys_dup>:
{
    8000550a:	7179                	add	sp,sp,-48
    8000550c:	f406                	sd	ra,40(sp)
    8000550e:	f022                	sd	s0,32(sp)
    80005510:	ec26                	sd	s1,24(sp)
    80005512:	e84a                	sd	s2,16(sp)
    80005514:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005516:	fd840613          	add	a2,s0,-40
    8000551a:	4581                	li	a1,0
    8000551c:	4501                	li	a0,0
    8000551e:	00000097          	auipc	ra,0x0
    80005522:	dc8080e7          	jalr	-568(ra) # 800052e6 <argfd>
    return -1;
    80005526:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005528:	02054363          	bltz	a0,8000554e <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000552c:	fd843903          	ld	s2,-40(s0)
    80005530:	854a                	mv	a0,s2
    80005532:	00000097          	auipc	ra,0x0
    80005536:	e14080e7          	jalr	-492(ra) # 80005346 <fdalloc>
    8000553a:	84aa                	mv	s1,a0
    return -1;
    8000553c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000553e:	00054863          	bltz	a0,8000554e <sys_dup+0x44>
  filedup(f);
    80005542:	854a                	mv	a0,s2
    80005544:	fffff097          	auipc	ra,0xfffff
    80005548:	334080e7          	jalr	820(ra) # 80004878 <filedup>
  return fd;
    8000554c:	87a6                	mv	a5,s1
}
    8000554e:	853e                	mv	a0,a5
    80005550:	70a2                	ld	ra,40(sp)
    80005552:	7402                	ld	s0,32(sp)
    80005554:	64e2                	ld	s1,24(sp)
    80005556:	6942                	ld	s2,16(sp)
    80005558:	6145                	add	sp,sp,48
    8000555a:	8082                	ret

000000008000555c <sys_read>:
{
    8000555c:	7179                	add	sp,sp,-48
    8000555e:	f406                	sd	ra,40(sp)
    80005560:	f022                	sd	s0,32(sp)
    80005562:	1800                	add	s0,sp,48
  acquire(&readcountlock); // Acquire the lock to protect readcount
    80005564:	0001c517          	auipc	a0,0x1c
    80005568:	29450513          	add	a0,a0,660 # 800217f8 <readcountlock>
    8000556c:	ffffb097          	auipc	ra,0xffffb
    80005570:	666080e7          	jalr	1638(ra) # 80000bd2 <acquire>
  readcount++; // Increment the readcount variable
    80005574:	00003717          	auipc	a4,0x3
    80005578:	3a070713          	add	a4,a4,928 # 80008914 <readcount>
    8000557c:	431c                	lw	a5,0(a4)
    8000557e:	2785                	addw	a5,a5,1
    80005580:	c31c                	sw	a5,0(a4)
  release(&readcountlock); // Release the lock  
    80005582:	0001c517          	auipc	a0,0x1c
    80005586:	27650513          	add	a0,a0,630 # 800217f8 <readcountlock>
    8000558a:	ffffb097          	auipc	ra,0xffffb
    8000558e:	6fc080e7          	jalr	1788(ra) # 80000c86 <release>
  argaddr(1, &p);
    80005592:	fd840593          	add	a1,s0,-40
    80005596:	4505                	li	a0,1
    80005598:	ffffd097          	auipc	ra,0xffffd
    8000559c:	7f6080e7          	jalr	2038(ra) # 80002d8e <argaddr>
  argint(2, &n);
    800055a0:	fe440593          	add	a1,s0,-28
    800055a4:	4509                	li	a0,2
    800055a6:	ffffd097          	auipc	ra,0xffffd
    800055aa:	7c8080e7          	jalr	1992(ra) # 80002d6e <argint>
  if(argfd(0, 0, &f) < 0)
    800055ae:	fe840613          	add	a2,s0,-24
    800055b2:	4581                	li	a1,0
    800055b4:	4501                	li	a0,0
    800055b6:	00000097          	auipc	ra,0x0
    800055ba:	d30080e7          	jalr	-720(ra) # 800052e6 <argfd>
    800055be:	87aa                	mv	a5,a0
    return -1;
    800055c0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055c2:	0007cc63          	bltz	a5,800055da <sys_read+0x7e>
  return fileread(f, p, n);
    800055c6:	fe442603          	lw	a2,-28(s0)
    800055ca:	fd843583          	ld	a1,-40(s0)
    800055ce:	fe843503          	ld	a0,-24(s0)
    800055d2:	fffff097          	auipc	ra,0xfffff
    800055d6:	432080e7          	jalr	1074(ra) # 80004a04 <fileread>
}
    800055da:	70a2                	ld	ra,40(sp)
    800055dc:	7402                	ld	s0,32(sp)
    800055de:	6145                	add	sp,sp,48
    800055e0:	8082                	ret

00000000800055e2 <sys_write>:
{
    800055e2:	7179                	add	sp,sp,-48
    800055e4:	f406                	sd	ra,40(sp)
    800055e6:	f022                	sd	s0,32(sp)
    800055e8:	1800                	add	s0,sp,48
  argaddr(1, &p);
    800055ea:	fd840593          	add	a1,s0,-40
    800055ee:	4505                	li	a0,1
    800055f0:	ffffd097          	auipc	ra,0xffffd
    800055f4:	79e080e7          	jalr	1950(ra) # 80002d8e <argaddr>
  argint(2, &n);
    800055f8:	fe440593          	add	a1,s0,-28
    800055fc:	4509                	li	a0,2
    800055fe:	ffffd097          	auipc	ra,0xffffd
    80005602:	770080e7          	jalr	1904(ra) # 80002d6e <argint>
  if(argfd(0, 0, &f) < 0)
    80005606:	fe840613          	add	a2,s0,-24
    8000560a:	4581                	li	a1,0
    8000560c:	4501                	li	a0,0
    8000560e:	00000097          	auipc	ra,0x0
    80005612:	cd8080e7          	jalr	-808(ra) # 800052e6 <argfd>
    80005616:	87aa                	mv	a5,a0
    return -1;
    80005618:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000561a:	0007cc63          	bltz	a5,80005632 <sys_write+0x50>
  return filewrite(f, p, n);
    8000561e:	fe442603          	lw	a2,-28(s0)
    80005622:	fd843583          	ld	a1,-40(s0)
    80005626:	fe843503          	ld	a0,-24(s0)
    8000562a:	fffff097          	auipc	ra,0xfffff
    8000562e:	49c080e7          	jalr	1180(ra) # 80004ac6 <filewrite>
}
    80005632:	70a2                	ld	ra,40(sp)
    80005634:	7402                	ld	s0,32(sp)
    80005636:	6145                	add	sp,sp,48
    80005638:	8082                	ret

000000008000563a <sys_close>:
{
    8000563a:	1101                	add	sp,sp,-32
    8000563c:	ec06                	sd	ra,24(sp)
    8000563e:	e822                	sd	s0,16(sp)
    80005640:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005642:	fe040613          	add	a2,s0,-32
    80005646:	fec40593          	add	a1,s0,-20
    8000564a:	4501                	li	a0,0
    8000564c:	00000097          	auipc	ra,0x0
    80005650:	c9a080e7          	jalr	-870(ra) # 800052e6 <argfd>
    return -1;
    80005654:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005656:	02054463          	bltz	a0,8000567e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000565a:	ffffc097          	auipc	ra,0xffffc
    8000565e:	34c080e7          	jalr	844(ra) # 800019a6 <myproc>
    80005662:	fec42783          	lw	a5,-20(s0)
    80005666:	07e9                	add	a5,a5,26
    80005668:	078e                	sll	a5,a5,0x3
    8000566a:	953e                	add	a0,a0,a5
    8000566c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005670:	fe043503          	ld	a0,-32(s0)
    80005674:	fffff097          	auipc	ra,0xfffff
    80005678:	256080e7          	jalr	598(ra) # 800048ca <fileclose>
  return 0;
    8000567c:	4781                	li	a5,0
}
    8000567e:	853e                	mv	a0,a5
    80005680:	60e2                	ld	ra,24(sp)
    80005682:	6442                	ld	s0,16(sp)
    80005684:	6105                	add	sp,sp,32
    80005686:	8082                	ret

0000000080005688 <sys_fstat>:
{
    80005688:	1101                	add	sp,sp,-32
    8000568a:	ec06                	sd	ra,24(sp)
    8000568c:	e822                	sd	s0,16(sp)
    8000568e:	1000                	add	s0,sp,32
  argaddr(1, &st);
    80005690:	fe040593          	add	a1,s0,-32
    80005694:	4505                	li	a0,1
    80005696:	ffffd097          	auipc	ra,0xffffd
    8000569a:	6f8080e7          	jalr	1784(ra) # 80002d8e <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000569e:	fe840613          	add	a2,s0,-24
    800056a2:	4581                	li	a1,0
    800056a4:	4501                	li	a0,0
    800056a6:	00000097          	auipc	ra,0x0
    800056aa:	c40080e7          	jalr	-960(ra) # 800052e6 <argfd>
    800056ae:	87aa                	mv	a5,a0
    return -1;
    800056b0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056b2:	0007ca63          	bltz	a5,800056c6 <sys_fstat+0x3e>
  return filestat(f, st);
    800056b6:	fe043583          	ld	a1,-32(s0)
    800056ba:	fe843503          	ld	a0,-24(s0)
    800056be:	fffff097          	auipc	ra,0xfffff
    800056c2:	2d4080e7          	jalr	724(ra) # 80004992 <filestat>
}
    800056c6:	60e2                	ld	ra,24(sp)
    800056c8:	6442                	ld	s0,16(sp)
    800056ca:	6105                	add	sp,sp,32
    800056cc:	8082                	ret

00000000800056ce <sys_link>:
{
    800056ce:	7169                	add	sp,sp,-304
    800056d0:	f606                	sd	ra,296(sp)
    800056d2:	f222                	sd	s0,288(sp)
    800056d4:	ee26                	sd	s1,280(sp)
    800056d6:	ea4a                	sd	s2,272(sp)
    800056d8:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056da:	08000613          	li	a2,128
    800056de:	ed040593          	add	a1,s0,-304
    800056e2:	4501                	li	a0,0
    800056e4:	ffffd097          	auipc	ra,0xffffd
    800056e8:	6ca080e7          	jalr	1738(ra) # 80002dae <argstr>
    return -1;
    800056ec:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800056ee:	10054e63          	bltz	a0,8000580a <sys_link+0x13c>
    800056f2:	08000613          	li	a2,128
    800056f6:	f5040593          	add	a1,s0,-176
    800056fa:	4505                	li	a0,1
    800056fc:	ffffd097          	auipc	ra,0xffffd
    80005700:	6b2080e7          	jalr	1714(ra) # 80002dae <argstr>
    return -1;
    80005704:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005706:	10054263          	bltz	a0,8000580a <sys_link+0x13c>
  begin_op();
    8000570a:	fffff097          	auipc	ra,0xfffff
    8000570e:	ce4080e7          	jalr	-796(ra) # 800043ee <begin_op>
  if((ip = namei(old)) == 0){
    80005712:	ed040513          	add	a0,s0,-304
    80005716:	fffff097          	auipc	ra,0xfffff
    8000571a:	ad8080e7          	jalr	-1320(ra) # 800041ee <namei>
    8000571e:	84aa                	mv	s1,a0
    80005720:	c551                	beqz	a0,800057ac <sys_link+0xde>
  ilock(ip);
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	326080e7          	jalr	806(ra) # 80003a48 <ilock>
  if(ip->type == T_DIR){
    8000572a:	04449703          	lh	a4,68(s1)
    8000572e:	4785                	li	a5,1
    80005730:	08f70463          	beq	a4,a5,800057b8 <sys_link+0xea>
  ip->nlink++;
    80005734:	04a4d783          	lhu	a5,74(s1)
    80005738:	2785                	addw	a5,a5,1
    8000573a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000573e:	8526                	mv	a0,s1
    80005740:	ffffe097          	auipc	ra,0xffffe
    80005744:	23c080e7          	jalr	572(ra) # 8000397c <iupdate>
  iunlock(ip);
    80005748:	8526                	mv	a0,s1
    8000574a:	ffffe097          	auipc	ra,0xffffe
    8000574e:	3c0080e7          	jalr	960(ra) # 80003b0a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005752:	fd040593          	add	a1,s0,-48
    80005756:	f5040513          	add	a0,s0,-176
    8000575a:	fffff097          	auipc	ra,0xfffff
    8000575e:	ab2080e7          	jalr	-1358(ra) # 8000420c <nameiparent>
    80005762:	892a                	mv	s2,a0
    80005764:	c935                	beqz	a0,800057d8 <sys_link+0x10a>
  ilock(dp);
    80005766:	ffffe097          	auipc	ra,0xffffe
    8000576a:	2e2080e7          	jalr	738(ra) # 80003a48 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000576e:	00092703          	lw	a4,0(s2)
    80005772:	409c                	lw	a5,0(s1)
    80005774:	04f71d63          	bne	a4,a5,800057ce <sys_link+0x100>
    80005778:	40d0                	lw	a2,4(s1)
    8000577a:	fd040593          	add	a1,s0,-48
    8000577e:	854a                	mv	a0,s2
    80005780:	fffff097          	auipc	ra,0xfffff
    80005784:	9bc080e7          	jalr	-1604(ra) # 8000413c <dirlink>
    80005788:	04054363          	bltz	a0,800057ce <sys_link+0x100>
  iunlockput(dp);
    8000578c:	854a                	mv	a0,s2
    8000578e:	ffffe097          	auipc	ra,0xffffe
    80005792:	51c080e7          	jalr	1308(ra) # 80003caa <iunlockput>
  iput(ip);
    80005796:	8526                	mv	a0,s1
    80005798:	ffffe097          	auipc	ra,0xffffe
    8000579c:	46a080e7          	jalr	1130(ra) # 80003c02 <iput>
  end_op();
    800057a0:	fffff097          	auipc	ra,0xfffff
    800057a4:	cc8080e7          	jalr	-824(ra) # 80004468 <end_op>
  return 0;
    800057a8:	4781                	li	a5,0
    800057aa:	a085                	j	8000580a <sys_link+0x13c>
    end_op();
    800057ac:	fffff097          	auipc	ra,0xfffff
    800057b0:	cbc080e7          	jalr	-836(ra) # 80004468 <end_op>
    return -1;
    800057b4:	57fd                	li	a5,-1
    800057b6:	a891                	j	8000580a <sys_link+0x13c>
    iunlockput(ip);
    800057b8:	8526                	mv	a0,s1
    800057ba:	ffffe097          	auipc	ra,0xffffe
    800057be:	4f0080e7          	jalr	1264(ra) # 80003caa <iunlockput>
    end_op();
    800057c2:	fffff097          	auipc	ra,0xfffff
    800057c6:	ca6080e7          	jalr	-858(ra) # 80004468 <end_op>
    return -1;
    800057ca:	57fd                	li	a5,-1
    800057cc:	a83d                	j	8000580a <sys_link+0x13c>
    iunlockput(dp);
    800057ce:	854a                	mv	a0,s2
    800057d0:	ffffe097          	auipc	ra,0xffffe
    800057d4:	4da080e7          	jalr	1242(ra) # 80003caa <iunlockput>
  ilock(ip);
    800057d8:	8526                	mv	a0,s1
    800057da:	ffffe097          	auipc	ra,0xffffe
    800057de:	26e080e7          	jalr	622(ra) # 80003a48 <ilock>
  ip->nlink--;
    800057e2:	04a4d783          	lhu	a5,74(s1)
    800057e6:	37fd                	addw	a5,a5,-1
    800057e8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800057ec:	8526                	mv	a0,s1
    800057ee:	ffffe097          	auipc	ra,0xffffe
    800057f2:	18e080e7          	jalr	398(ra) # 8000397c <iupdate>
  iunlockput(ip);
    800057f6:	8526                	mv	a0,s1
    800057f8:	ffffe097          	auipc	ra,0xffffe
    800057fc:	4b2080e7          	jalr	1202(ra) # 80003caa <iunlockput>
  end_op();
    80005800:	fffff097          	auipc	ra,0xfffff
    80005804:	c68080e7          	jalr	-920(ra) # 80004468 <end_op>
  return -1;
    80005808:	57fd                	li	a5,-1
}
    8000580a:	853e                	mv	a0,a5
    8000580c:	70b2                	ld	ra,296(sp)
    8000580e:	7412                	ld	s0,288(sp)
    80005810:	64f2                	ld	s1,280(sp)
    80005812:	6952                	ld	s2,272(sp)
    80005814:	6155                	add	sp,sp,304
    80005816:	8082                	ret

0000000080005818 <sys_unlink>:
{
    80005818:	7151                	add	sp,sp,-240
    8000581a:	f586                	sd	ra,232(sp)
    8000581c:	f1a2                	sd	s0,224(sp)
    8000581e:	eda6                	sd	s1,216(sp)
    80005820:	e9ca                	sd	s2,208(sp)
    80005822:	e5ce                	sd	s3,200(sp)
    80005824:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005826:	08000613          	li	a2,128
    8000582a:	f3040593          	add	a1,s0,-208
    8000582e:	4501                	li	a0,0
    80005830:	ffffd097          	auipc	ra,0xffffd
    80005834:	57e080e7          	jalr	1406(ra) # 80002dae <argstr>
    80005838:	18054163          	bltz	a0,800059ba <sys_unlink+0x1a2>
  begin_op();
    8000583c:	fffff097          	auipc	ra,0xfffff
    80005840:	bb2080e7          	jalr	-1102(ra) # 800043ee <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005844:	fb040593          	add	a1,s0,-80
    80005848:	f3040513          	add	a0,s0,-208
    8000584c:	fffff097          	auipc	ra,0xfffff
    80005850:	9c0080e7          	jalr	-1600(ra) # 8000420c <nameiparent>
    80005854:	84aa                	mv	s1,a0
    80005856:	c979                	beqz	a0,8000592c <sys_unlink+0x114>
  ilock(dp);
    80005858:	ffffe097          	auipc	ra,0xffffe
    8000585c:	1f0080e7          	jalr	496(ra) # 80003a48 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005860:	00003597          	auipc	a1,0x3
    80005864:	ec058593          	add	a1,a1,-320 # 80008720 <syscalls+0x2d0>
    80005868:	fb040513          	add	a0,s0,-80
    8000586c:	ffffe097          	auipc	ra,0xffffe
    80005870:	6a6080e7          	jalr	1702(ra) # 80003f12 <namecmp>
    80005874:	14050a63          	beqz	a0,800059c8 <sys_unlink+0x1b0>
    80005878:	00003597          	auipc	a1,0x3
    8000587c:	eb058593          	add	a1,a1,-336 # 80008728 <syscalls+0x2d8>
    80005880:	fb040513          	add	a0,s0,-80
    80005884:	ffffe097          	auipc	ra,0xffffe
    80005888:	68e080e7          	jalr	1678(ra) # 80003f12 <namecmp>
    8000588c:	12050e63          	beqz	a0,800059c8 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005890:	f2c40613          	add	a2,s0,-212
    80005894:	fb040593          	add	a1,s0,-80
    80005898:	8526                	mv	a0,s1
    8000589a:	ffffe097          	auipc	ra,0xffffe
    8000589e:	692080e7          	jalr	1682(ra) # 80003f2c <dirlookup>
    800058a2:	892a                	mv	s2,a0
    800058a4:	12050263          	beqz	a0,800059c8 <sys_unlink+0x1b0>
  ilock(ip);
    800058a8:	ffffe097          	auipc	ra,0xffffe
    800058ac:	1a0080e7          	jalr	416(ra) # 80003a48 <ilock>
  if(ip->nlink < 1)
    800058b0:	04a91783          	lh	a5,74(s2)
    800058b4:	08f05263          	blez	a5,80005938 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800058b8:	04491703          	lh	a4,68(s2)
    800058bc:	4785                	li	a5,1
    800058be:	08f70563          	beq	a4,a5,80005948 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800058c2:	4641                	li	a2,16
    800058c4:	4581                	li	a1,0
    800058c6:	fc040513          	add	a0,s0,-64
    800058ca:	ffffb097          	auipc	ra,0xffffb
    800058ce:	404080e7          	jalr	1028(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800058d2:	4741                	li	a4,16
    800058d4:	f2c42683          	lw	a3,-212(s0)
    800058d8:	fc040613          	add	a2,s0,-64
    800058dc:	4581                	li	a1,0
    800058de:	8526                	mv	a0,s1
    800058e0:	ffffe097          	auipc	ra,0xffffe
    800058e4:	514080e7          	jalr	1300(ra) # 80003df4 <writei>
    800058e8:	47c1                	li	a5,16
    800058ea:	0af51563          	bne	a0,a5,80005994 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800058ee:	04491703          	lh	a4,68(s2)
    800058f2:	4785                	li	a5,1
    800058f4:	0af70863          	beq	a4,a5,800059a4 <sys_unlink+0x18c>
  iunlockput(dp);
    800058f8:	8526                	mv	a0,s1
    800058fa:	ffffe097          	auipc	ra,0xffffe
    800058fe:	3b0080e7          	jalr	944(ra) # 80003caa <iunlockput>
  ip->nlink--;
    80005902:	04a95783          	lhu	a5,74(s2)
    80005906:	37fd                	addw	a5,a5,-1
    80005908:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000590c:	854a                	mv	a0,s2
    8000590e:	ffffe097          	auipc	ra,0xffffe
    80005912:	06e080e7          	jalr	110(ra) # 8000397c <iupdate>
  iunlockput(ip);
    80005916:	854a                	mv	a0,s2
    80005918:	ffffe097          	auipc	ra,0xffffe
    8000591c:	392080e7          	jalr	914(ra) # 80003caa <iunlockput>
  end_op();
    80005920:	fffff097          	auipc	ra,0xfffff
    80005924:	b48080e7          	jalr	-1208(ra) # 80004468 <end_op>
  return 0;
    80005928:	4501                	li	a0,0
    8000592a:	a84d                	j	800059dc <sys_unlink+0x1c4>
    end_op();
    8000592c:	fffff097          	auipc	ra,0xfffff
    80005930:	b3c080e7          	jalr	-1220(ra) # 80004468 <end_op>
    return -1;
    80005934:	557d                	li	a0,-1
    80005936:	a05d                	j	800059dc <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005938:	00003517          	auipc	a0,0x3
    8000593c:	df850513          	add	a0,a0,-520 # 80008730 <syscalls+0x2e0>
    80005940:	ffffb097          	auipc	ra,0xffffb
    80005944:	bfc080e7          	jalr	-1028(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005948:	04c92703          	lw	a4,76(s2)
    8000594c:	02000793          	li	a5,32
    80005950:	f6e7f9e3          	bgeu	a5,a4,800058c2 <sys_unlink+0xaa>
    80005954:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005958:	4741                	li	a4,16
    8000595a:	86ce                	mv	a3,s3
    8000595c:	f1840613          	add	a2,s0,-232
    80005960:	4581                	li	a1,0
    80005962:	854a                	mv	a0,s2
    80005964:	ffffe097          	auipc	ra,0xffffe
    80005968:	398080e7          	jalr	920(ra) # 80003cfc <readi>
    8000596c:	47c1                	li	a5,16
    8000596e:	00f51b63          	bne	a0,a5,80005984 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005972:	f1845783          	lhu	a5,-232(s0)
    80005976:	e7a1                	bnez	a5,800059be <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005978:	29c1                	addw	s3,s3,16
    8000597a:	04c92783          	lw	a5,76(s2)
    8000597e:	fcf9ede3          	bltu	s3,a5,80005958 <sys_unlink+0x140>
    80005982:	b781                	j	800058c2 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005984:	00003517          	auipc	a0,0x3
    80005988:	dc450513          	add	a0,a0,-572 # 80008748 <syscalls+0x2f8>
    8000598c:	ffffb097          	auipc	ra,0xffffb
    80005990:	bb0080e7          	jalr	-1104(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005994:	00003517          	auipc	a0,0x3
    80005998:	dcc50513          	add	a0,a0,-564 # 80008760 <syscalls+0x310>
    8000599c:	ffffb097          	auipc	ra,0xffffb
    800059a0:	ba0080e7          	jalr	-1120(ra) # 8000053c <panic>
    dp->nlink--;
    800059a4:	04a4d783          	lhu	a5,74(s1)
    800059a8:	37fd                	addw	a5,a5,-1
    800059aa:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800059ae:	8526                	mv	a0,s1
    800059b0:	ffffe097          	auipc	ra,0xffffe
    800059b4:	fcc080e7          	jalr	-52(ra) # 8000397c <iupdate>
    800059b8:	b781                	j	800058f8 <sys_unlink+0xe0>
    return -1;
    800059ba:	557d                	li	a0,-1
    800059bc:	a005                	j	800059dc <sys_unlink+0x1c4>
    iunlockput(ip);
    800059be:	854a                	mv	a0,s2
    800059c0:	ffffe097          	auipc	ra,0xffffe
    800059c4:	2ea080e7          	jalr	746(ra) # 80003caa <iunlockput>
  iunlockput(dp);
    800059c8:	8526                	mv	a0,s1
    800059ca:	ffffe097          	auipc	ra,0xffffe
    800059ce:	2e0080e7          	jalr	736(ra) # 80003caa <iunlockput>
  end_op();
    800059d2:	fffff097          	auipc	ra,0xfffff
    800059d6:	a96080e7          	jalr	-1386(ra) # 80004468 <end_op>
  return -1;
    800059da:	557d                	li	a0,-1
}
    800059dc:	70ae                	ld	ra,232(sp)
    800059de:	740e                	ld	s0,224(sp)
    800059e0:	64ee                	ld	s1,216(sp)
    800059e2:	694e                	ld	s2,208(sp)
    800059e4:	69ae                	ld	s3,200(sp)
    800059e6:	616d                	add	sp,sp,240
    800059e8:	8082                	ret

00000000800059ea <sys_open>:

uint64
sys_open(void)
{
    800059ea:	7131                	add	sp,sp,-192
    800059ec:	fd06                	sd	ra,184(sp)
    800059ee:	f922                	sd	s0,176(sp)
    800059f0:	f526                	sd	s1,168(sp)
    800059f2:	f14a                	sd	s2,160(sp)
    800059f4:	ed4e                	sd	s3,152(sp)
    800059f6:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800059f8:	f4c40593          	add	a1,s0,-180
    800059fc:	4505                	li	a0,1
    800059fe:	ffffd097          	auipc	ra,0xffffd
    80005a02:	370080e7          	jalr	880(ra) # 80002d6e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a06:	08000613          	li	a2,128
    80005a0a:	f5040593          	add	a1,s0,-176
    80005a0e:	4501                	li	a0,0
    80005a10:	ffffd097          	auipc	ra,0xffffd
    80005a14:	39e080e7          	jalr	926(ra) # 80002dae <argstr>
    80005a18:	87aa                	mv	a5,a0
    return -1;
    80005a1a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005a1c:	0a07c863          	bltz	a5,80005acc <sys_open+0xe2>

  begin_op();
    80005a20:	fffff097          	auipc	ra,0xfffff
    80005a24:	9ce080e7          	jalr	-1586(ra) # 800043ee <begin_op>

  if(omode & O_CREATE){
    80005a28:	f4c42783          	lw	a5,-180(s0)
    80005a2c:	2007f793          	and	a5,a5,512
    80005a30:	cbdd                	beqz	a5,80005ae6 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005a32:	4681                	li	a3,0
    80005a34:	4601                	li	a2,0
    80005a36:	4589                	li	a1,2
    80005a38:	f5040513          	add	a0,s0,-176
    80005a3c:	00000097          	auipc	ra,0x0
    80005a40:	94c080e7          	jalr	-1716(ra) # 80005388 <create>
    80005a44:	84aa                	mv	s1,a0
    if(ip == 0){
    80005a46:	c951                	beqz	a0,80005ada <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a48:	04449703          	lh	a4,68(s1)
    80005a4c:	478d                	li	a5,3
    80005a4e:	00f71763          	bne	a4,a5,80005a5c <sys_open+0x72>
    80005a52:	0464d703          	lhu	a4,70(s1)
    80005a56:	47a5                	li	a5,9
    80005a58:	0ce7ec63          	bltu	a5,a4,80005b30 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a5c:	fffff097          	auipc	ra,0xfffff
    80005a60:	db2080e7          	jalr	-590(ra) # 8000480e <filealloc>
    80005a64:	892a                	mv	s2,a0
    80005a66:	c56d                	beqz	a0,80005b50 <sys_open+0x166>
    80005a68:	00000097          	auipc	ra,0x0
    80005a6c:	8de080e7          	jalr	-1826(ra) # 80005346 <fdalloc>
    80005a70:	89aa                	mv	s3,a0
    80005a72:	0c054a63          	bltz	a0,80005b46 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005a76:	04449703          	lh	a4,68(s1)
    80005a7a:	478d                	li	a5,3
    80005a7c:	0ef70563          	beq	a4,a5,80005b66 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005a80:	4789                	li	a5,2
    80005a82:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005a86:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005a8a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005a8e:	f4c42783          	lw	a5,-180(s0)
    80005a92:	0017c713          	xor	a4,a5,1
    80005a96:	8b05                	and	a4,a4,1
    80005a98:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005a9c:	0037f713          	and	a4,a5,3
    80005aa0:	00e03733          	snez	a4,a4
    80005aa4:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005aa8:	4007f793          	and	a5,a5,1024
    80005aac:	c791                	beqz	a5,80005ab8 <sys_open+0xce>
    80005aae:	04449703          	lh	a4,68(s1)
    80005ab2:	4789                	li	a5,2
    80005ab4:	0cf70063          	beq	a4,a5,80005b74 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    80005ab8:	8526                	mv	a0,s1
    80005aba:	ffffe097          	auipc	ra,0xffffe
    80005abe:	050080e7          	jalr	80(ra) # 80003b0a <iunlock>
  end_op();
    80005ac2:	fffff097          	auipc	ra,0xfffff
    80005ac6:	9a6080e7          	jalr	-1626(ra) # 80004468 <end_op>

  return fd;
    80005aca:	854e                	mv	a0,s3
}
    80005acc:	70ea                	ld	ra,184(sp)
    80005ace:	744a                	ld	s0,176(sp)
    80005ad0:	74aa                	ld	s1,168(sp)
    80005ad2:	790a                	ld	s2,160(sp)
    80005ad4:	69ea                	ld	s3,152(sp)
    80005ad6:	6129                	add	sp,sp,192
    80005ad8:	8082                	ret
      end_op();
    80005ada:	fffff097          	auipc	ra,0xfffff
    80005ade:	98e080e7          	jalr	-1650(ra) # 80004468 <end_op>
      return -1;
    80005ae2:	557d                	li	a0,-1
    80005ae4:	b7e5                	j	80005acc <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    80005ae6:	f5040513          	add	a0,s0,-176
    80005aea:	ffffe097          	auipc	ra,0xffffe
    80005aee:	704080e7          	jalr	1796(ra) # 800041ee <namei>
    80005af2:	84aa                	mv	s1,a0
    80005af4:	c905                	beqz	a0,80005b24 <sys_open+0x13a>
    ilock(ip);
    80005af6:	ffffe097          	auipc	ra,0xffffe
    80005afa:	f52080e7          	jalr	-174(ra) # 80003a48 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005afe:	04449703          	lh	a4,68(s1)
    80005b02:	4785                	li	a5,1
    80005b04:	f4f712e3          	bne	a4,a5,80005a48 <sys_open+0x5e>
    80005b08:	f4c42783          	lw	a5,-180(s0)
    80005b0c:	dba1                	beqz	a5,80005a5c <sys_open+0x72>
      iunlockput(ip);
    80005b0e:	8526                	mv	a0,s1
    80005b10:	ffffe097          	auipc	ra,0xffffe
    80005b14:	19a080e7          	jalr	410(ra) # 80003caa <iunlockput>
      end_op();
    80005b18:	fffff097          	auipc	ra,0xfffff
    80005b1c:	950080e7          	jalr	-1712(ra) # 80004468 <end_op>
      return -1;
    80005b20:	557d                	li	a0,-1
    80005b22:	b76d                	j	80005acc <sys_open+0xe2>
      end_op();
    80005b24:	fffff097          	auipc	ra,0xfffff
    80005b28:	944080e7          	jalr	-1724(ra) # 80004468 <end_op>
      return -1;
    80005b2c:	557d                	li	a0,-1
    80005b2e:	bf79                	j	80005acc <sys_open+0xe2>
    iunlockput(ip);
    80005b30:	8526                	mv	a0,s1
    80005b32:	ffffe097          	auipc	ra,0xffffe
    80005b36:	178080e7          	jalr	376(ra) # 80003caa <iunlockput>
    end_op();
    80005b3a:	fffff097          	auipc	ra,0xfffff
    80005b3e:	92e080e7          	jalr	-1746(ra) # 80004468 <end_op>
    return -1;
    80005b42:	557d                	li	a0,-1
    80005b44:	b761                	j	80005acc <sys_open+0xe2>
      fileclose(f);
    80005b46:	854a                	mv	a0,s2
    80005b48:	fffff097          	auipc	ra,0xfffff
    80005b4c:	d82080e7          	jalr	-638(ra) # 800048ca <fileclose>
    iunlockput(ip);
    80005b50:	8526                	mv	a0,s1
    80005b52:	ffffe097          	auipc	ra,0xffffe
    80005b56:	158080e7          	jalr	344(ra) # 80003caa <iunlockput>
    end_op();
    80005b5a:	fffff097          	auipc	ra,0xfffff
    80005b5e:	90e080e7          	jalr	-1778(ra) # 80004468 <end_op>
    return -1;
    80005b62:	557d                	li	a0,-1
    80005b64:	b7a5                	j	80005acc <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005b66:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005b6a:	04649783          	lh	a5,70(s1)
    80005b6e:	02f91223          	sh	a5,36(s2)
    80005b72:	bf21                	j	80005a8a <sys_open+0xa0>
    itrunc(ip);
    80005b74:	8526                	mv	a0,s1
    80005b76:	ffffe097          	auipc	ra,0xffffe
    80005b7a:	fe0080e7          	jalr	-32(ra) # 80003b56 <itrunc>
    80005b7e:	bf2d                	j	80005ab8 <sys_open+0xce>

0000000080005b80 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005b80:	7175                	add	sp,sp,-144
    80005b82:	e506                	sd	ra,136(sp)
    80005b84:	e122                	sd	s0,128(sp)
    80005b86:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005b88:	fffff097          	auipc	ra,0xfffff
    80005b8c:	866080e7          	jalr	-1946(ra) # 800043ee <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005b90:	08000613          	li	a2,128
    80005b94:	f7040593          	add	a1,s0,-144
    80005b98:	4501                	li	a0,0
    80005b9a:	ffffd097          	auipc	ra,0xffffd
    80005b9e:	214080e7          	jalr	532(ra) # 80002dae <argstr>
    80005ba2:	02054963          	bltz	a0,80005bd4 <sys_mkdir+0x54>
    80005ba6:	4681                	li	a3,0
    80005ba8:	4601                	li	a2,0
    80005baa:	4585                	li	a1,1
    80005bac:	f7040513          	add	a0,s0,-144
    80005bb0:	fffff097          	auipc	ra,0xfffff
    80005bb4:	7d8080e7          	jalr	2008(ra) # 80005388 <create>
    80005bb8:	cd11                	beqz	a0,80005bd4 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	0f0080e7          	jalr	240(ra) # 80003caa <iunlockput>
  end_op();
    80005bc2:	fffff097          	auipc	ra,0xfffff
    80005bc6:	8a6080e7          	jalr	-1882(ra) # 80004468 <end_op>
  return 0;
    80005bca:	4501                	li	a0,0
}
    80005bcc:	60aa                	ld	ra,136(sp)
    80005bce:	640a                	ld	s0,128(sp)
    80005bd0:	6149                	add	sp,sp,144
    80005bd2:	8082                	ret
    end_op();
    80005bd4:	fffff097          	auipc	ra,0xfffff
    80005bd8:	894080e7          	jalr	-1900(ra) # 80004468 <end_op>
    return -1;
    80005bdc:	557d                	li	a0,-1
    80005bde:	b7fd                	j	80005bcc <sys_mkdir+0x4c>

0000000080005be0 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005be0:	7135                	add	sp,sp,-160
    80005be2:	ed06                	sd	ra,152(sp)
    80005be4:	e922                	sd	s0,144(sp)
    80005be6:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005be8:	fffff097          	auipc	ra,0xfffff
    80005bec:	806080e7          	jalr	-2042(ra) # 800043ee <begin_op>
  argint(1, &major);
    80005bf0:	f6c40593          	add	a1,s0,-148
    80005bf4:	4505                	li	a0,1
    80005bf6:	ffffd097          	auipc	ra,0xffffd
    80005bfa:	178080e7          	jalr	376(ra) # 80002d6e <argint>
  argint(2, &minor);
    80005bfe:	f6840593          	add	a1,s0,-152
    80005c02:	4509                	li	a0,2
    80005c04:	ffffd097          	auipc	ra,0xffffd
    80005c08:	16a080e7          	jalr	362(ra) # 80002d6e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c0c:	08000613          	li	a2,128
    80005c10:	f7040593          	add	a1,s0,-144
    80005c14:	4501                	li	a0,0
    80005c16:	ffffd097          	auipc	ra,0xffffd
    80005c1a:	198080e7          	jalr	408(ra) # 80002dae <argstr>
    80005c1e:	02054b63          	bltz	a0,80005c54 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c22:	f6841683          	lh	a3,-152(s0)
    80005c26:	f6c41603          	lh	a2,-148(s0)
    80005c2a:	458d                	li	a1,3
    80005c2c:	f7040513          	add	a0,s0,-144
    80005c30:	fffff097          	auipc	ra,0xfffff
    80005c34:	758080e7          	jalr	1880(ra) # 80005388 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c38:	cd11                	beqz	a0,80005c54 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c3a:	ffffe097          	auipc	ra,0xffffe
    80005c3e:	070080e7          	jalr	112(ra) # 80003caa <iunlockput>
  end_op();
    80005c42:	fffff097          	auipc	ra,0xfffff
    80005c46:	826080e7          	jalr	-2010(ra) # 80004468 <end_op>
  return 0;
    80005c4a:	4501                	li	a0,0
}
    80005c4c:	60ea                	ld	ra,152(sp)
    80005c4e:	644a                	ld	s0,144(sp)
    80005c50:	610d                	add	sp,sp,160
    80005c52:	8082                	ret
    end_op();
    80005c54:	fffff097          	auipc	ra,0xfffff
    80005c58:	814080e7          	jalr	-2028(ra) # 80004468 <end_op>
    return -1;
    80005c5c:	557d                	li	a0,-1
    80005c5e:	b7fd                	j	80005c4c <sys_mknod+0x6c>

0000000080005c60 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c60:	7135                	add	sp,sp,-160
    80005c62:	ed06                	sd	ra,152(sp)
    80005c64:	e922                	sd	s0,144(sp)
    80005c66:	e526                	sd	s1,136(sp)
    80005c68:	e14a                	sd	s2,128(sp)
    80005c6a:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005c6c:	ffffc097          	auipc	ra,0xffffc
    80005c70:	d3a080e7          	jalr	-710(ra) # 800019a6 <myproc>
    80005c74:	892a                	mv	s2,a0
  
  begin_op();
    80005c76:	ffffe097          	auipc	ra,0xffffe
    80005c7a:	778080e7          	jalr	1912(ra) # 800043ee <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005c7e:	08000613          	li	a2,128
    80005c82:	f6040593          	add	a1,s0,-160
    80005c86:	4501                	li	a0,0
    80005c88:	ffffd097          	auipc	ra,0xffffd
    80005c8c:	126080e7          	jalr	294(ra) # 80002dae <argstr>
    80005c90:	04054b63          	bltz	a0,80005ce6 <sys_chdir+0x86>
    80005c94:	f6040513          	add	a0,s0,-160
    80005c98:	ffffe097          	auipc	ra,0xffffe
    80005c9c:	556080e7          	jalr	1366(ra) # 800041ee <namei>
    80005ca0:	84aa                	mv	s1,a0
    80005ca2:	c131                	beqz	a0,80005ce6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005ca4:	ffffe097          	auipc	ra,0xffffe
    80005ca8:	da4080e7          	jalr	-604(ra) # 80003a48 <ilock>
  if(ip->type != T_DIR){
    80005cac:	04449703          	lh	a4,68(s1)
    80005cb0:	4785                	li	a5,1
    80005cb2:	04f71063          	bne	a4,a5,80005cf2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005cb6:	8526                	mv	a0,s1
    80005cb8:	ffffe097          	auipc	ra,0xffffe
    80005cbc:	e52080e7          	jalr	-430(ra) # 80003b0a <iunlock>
  iput(p->cwd);
    80005cc0:	15093503          	ld	a0,336(s2)
    80005cc4:	ffffe097          	auipc	ra,0xffffe
    80005cc8:	f3e080e7          	jalr	-194(ra) # 80003c02 <iput>
  end_op();
    80005ccc:	ffffe097          	auipc	ra,0xffffe
    80005cd0:	79c080e7          	jalr	1948(ra) # 80004468 <end_op>
  p->cwd = ip;
    80005cd4:	14993823          	sd	s1,336(s2)
  return 0;
    80005cd8:	4501                	li	a0,0
}
    80005cda:	60ea                	ld	ra,152(sp)
    80005cdc:	644a                	ld	s0,144(sp)
    80005cde:	64aa                	ld	s1,136(sp)
    80005ce0:	690a                	ld	s2,128(sp)
    80005ce2:	610d                	add	sp,sp,160
    80005ce4:	8082                	ret
    end_op();
    80005ce6:	ffffe097          	auipc	ra,0xffffe
    80005cea:	782080e7          	jalr	1922(ra) # 80004468 <end_op>
    return -1;
    80005cee:	557d                	li	a0,-1
    80005cf0:	b7ed                	j	80005cda <sys_chdir+0x7a>
    iunlockput(ip);
    80005cf2:	8526                	mv	a0,s1
    80005cf4:	ffffe097          	auipc	ra,0xffffe
    80005cf8:	fb6080e7          	jalr	-74(ra) # 80003caa <iunlockput>
    end_op();
    80005cfc:	ffffe097          	auipc	ra,0xffffe
    80005d00:	76c080e7          	jalr	1900(ra) # 80004468 <end_op>
    return -1;
    80005d04:	557d                	li	a0,-1
    80005d06:	bfd1                	j	80005cda <sys_chdir+0x7a>

0000000080005d08 <sys_exec>:

uint64
sys_exec(void)
{
    80005d08:	7121                	add	sp,sp,-448
    80005d0a:	ff06                	sd	ra,440(sp)
    80005d0c:	fb22                	sd	s0,432(sp)
    80005d0e:	f726                	sd	s1,424(sp)
    80005d10:	f34a                	sd	s2,416(sp)
    80005d12:	ef4e                	sd	s3,408(sp)
    80005d14:	eb52                	sd	s4,400(sp)
    80005d16:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005d18:	e4840593          	add	a1,s0,-440
    80005d1c:	4505                	li	a0,1
    80005d1e:	ffffd097          	auipc	ra,0xffffd
    80005d22:	070080e7          	jalr	112(ra) # 80002d8e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005d26:	08000613          	li	a2,128
    80005d2a:	f5040593          	add	a1,s0,-176
    80005d2e:	4501                	li	a0,0
    80005d30:	ffffd097          	auipc	ra,0xffffd
    80005d34:	07e080e7          	jalr	126(ra) # 80002dae <argstr>
    80005d38:	87aa                	mv	a5,a0
    return -1;
    80005d3a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005d3c:	0c07c263          	bltz	a5,80005e00 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005d40:	10000613          	li	a2,256
    80005d44:	4581                	li	a1,0
    80005d46:	e5040513          	add	a0,s0,-432
    80005d4a:	ffffb097          	auipc	ra,0xffffb
    80005d4e:	f84080e7          	jalr	-124(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d52:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005d56:	89a6                	mv	s3,s1
    80005d58:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005d5a:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d5e:	00391513          	sll	a0,s2,0x3
    80005d62:	e4040593          	add	a1,s0,-448
    80005d66:	e4843783          	ld	a5,-440(s0)
    80005d6a:	953e                	add	a0,a0,a5
    80005d6c:	ffffd097          	auipc	ra,0xffffd
    80005d70:	f64080e7          	jalr	-156(ra) # 80002cd0 <fetchaddr>
    80005d74:	02054a63          	bltz	a0,80005da8 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005d78:	e4043783          	ld	a5,-448(s0)
    80005d7c:	c3b9                	beqz	a5,80005dc2 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005d7e:	ffffb097          	auipc	ra,0xffffb
    80005d82:	d64080e7          	jalr	-668(ra) # 80000ae2 <kalloc>
    80005d86:	85aa                	mv	a1,a0
    80005d88:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005d8c:	cd11                	beqz	a0,80005da8 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005d8e:	6605                	lui	a2,0x1
    80005d90:	e4043503          	ld	a0,-448(s0)
    80005d94:	ffffd097          	auipc	ra,0xffffd
    80005d98:	f8e080e7          	jalr	-114(ra) # 80002d22 <fetchstr>
    80005d9c:	00054663          	bltz	a0,80005da8 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005da0:	0905                	add	s2,s2,1
    80005da2:	09a1                	add	s3,s3,8
    80005da4:	fb491de3          	bne	s2,s4,80005d5e <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005da8:	f5040913          	add	s2,s0,-176
    80005dac:	6088                	ld	a0,0(s1)
    80005dae:	c921                	beqz	a0,80005dfe <sys_exec+0xf6>
    kfree(argv[i]);
    80005db0:	ffffb097          	auipc	ra,0xffffb
    80005db4:	c34080e7          	jalr	-972(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005db8:	04a1                	add	s1,s1,8
    80005dba:	ff2499e3          	bne	s1,s2,80005dac <sys_exec+0xa4>
  return -1;
    80005dbe:	557d                	li	a0,-1
    80005dc0:	a081                	j	80005e00 <sys_exec+0xf8>
      argv[i] = 0;
    80005dc2:	0009079b          	sext.w	a5,s2
    80005dc6:	078e                	sll	a5,a5,0x3
    80005dc8:	fd078793          	add	a5,a5,-48
    80005dcc:	97a2                	add	a5,a5,s0
    80005dce:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005dd2:	e5040593          	add	a1,s0,-432
    80005dd6:	f5040513          	add	a0,s0,-176
    80005dda:	fffff097          	auipc	ra,0xfffff
    80005dde:	166080e7          	jalr	358(ra) # 80004f40 <exec>
    80005de2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005de4:	f5040993          	add	s3,s0,-176
    80005de8:	6088                	ld	a0,0(s1)
    80005dea:	c901                	beqz	a0,80005dfa <sys_exec+0xf2>
    kfree(argv[i]);
    80005dec:	ffffb097          	auipc	ra,0xffffb
    80005df0:	bf8080e7          	jalr	-1032(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005df4:	04a1                	add	s1,s1,8
    80005df6:	ff3499e3          	bne	s1,s3,80005de8 <sys_exec+0xe0>
  return ret;
    80005dfa:	854a                	mv	a0,s2
    80005dfc:	a011                	j	80005e00 <sys_exec+0xf8>
  return -1;
    80005dfe:	557d                	li	a0,-1
}
    80005e00:	70fa                	ld	ra,440(sp)
    80005e02:	745a                	ld	s0,432(sp)
    80005e04:	74ba                	ld	s1,424(sp)
    80005e06:	791a                	ld	s2,416(sp)
    80005e08:	69fa                	ld	s3,408(sp)
    80005e0a:	6a5a                	ld	s4,400(sp)
    80005e0c:	6139                	add	sp,sp,448
    80005e0e:	8082                	ret

0000000080005e10 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e10:	7139                	add	sp,sp,-64
    80005e12:	fc06                	sd	ra,56(sp)
    80005e14:	f822                	sd	s0,48(sp)
    80005e16:	f426                	sd	s1,40(sp)
    80005e18:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e1a:	ffffc097          	auipc	ra,0xffffc
    80005e1e:	b8c080e7          	jalr	-1140(ra) # 800019a6 <myproc>
    80005e22:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005e24:	fd840593          	add	a1,s0,-40
    80005e28:	4501                	li	a0,0
    80005e2a:	ffffd097          	auipc	ra,0xffffd
    80005e2e:	f64080e7          	jalr	-156(ra) # 80002d8e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005e32:	fc840593          	add	a1,s0,-56
    80005e36:	fd040513          	add	a0,s0,-48
    80005e3a:	fffff097          	auipc	ra,0xfffff
    80005e3e:	dbc080e7          	jalr	-580(ra) # 80004bf6 <pipealloc>
    return -1;
    80005e42:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005e44:	0c054463          	bltz	a0,80005f0c <sys_pipe+0xfc>
  fd0 = -1;
    80005e48:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005e4c:	fd043503          	ld	a0,-48(s0)
    80005e50:	fffff097          	auipc	ra,0xfffff
    80005e54:	4f6080e7          	jalr	1270(ra) # 80005346 <fdalloc>
    80005e58:	fca42223          	sw	a0,-60(s0)
    80005e5c:	08054b63          	bltz	a0,80005ef2 <sys_pipe+0xe2>
    80005e60:	fc843503          	ld	a0,-56(s0)
    80005e64:	fffff097          	auipc	ra,0xfffff
    80005e68:	4e2080e7          	jalr	1250(ra) # 80005346 <fdalloc>
    80005e6c:	fca42023          	sw	a0,-64(s0)
    80005e70:	06054863          	bltz	a0,80005ee0 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005e74:	4691                	li	a3,4
    80005e76:	fc440613          	add	a2,s0,-60
    80005e7a:	fd843583          	ld	a1,-40(s0)
    80005e7e:	68a8                	ld	a0,80(s1)
    80005e80:	ffffb097          	auipc	ra,0xffffb
    80005e84:	7e6080e7          	jalr	2022(ra) # 80001666 <copyout>
    80005e88:	02054063          	bltz	a0,80005ea8 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005e8c:	4691                	li	a3,4
    80005e8e:	fc040613          	add	a2,s0,-64
    80005e92:	fd843583          	ld	a1,-40(s0)
    80005e96:	0591                	add	a1,a1,4
    80005e98:	68a8                	ld	a0,80(s1)
    80005e9a:	ffffb097          	auipc	ra,0xffffb
    80005e9e:	7cc080e7          	jalr	1996(ra) # 80001666 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005ea2:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ea4:	06055463          	bgez	a0,80005f0c <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005ea8:	fc442783          	lw	a5,-60(s0)
    80005eac:	07e9                	add	a5,a5,26
    80005eae:	078e                	sll	a5,a5,0x3
    80005eb0:	97a6                	add	a5,a5,s1
    80005eb2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005eb6:	fc042783          	lw	a5,-64(s0)
    80005eba:	07e9                	add	a5,a5,26
    80005ebc:	078e                	sll	a5,a5,0x3
    80005ebe:	94be                	add	s1,s1,a5
    80005ec0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005ec4:	fd043503          	ld	a0,-48(s0)
    80005ec8:	fffff097          	auipc	ra,0xfffff
    80005ecc:	a02080e7          	jalr	-1534(ra) # 800048ca <fileclose>
    fileclose(wf);
    80005ed0:	fc843503          	ld	a0,-56(s0)
    80005ed4:	fffff097          	auipc	ra,0xfffff
    80005ed8:	9f6080e7          	jalr	-1546(ra) # 800048ca <fileclose>
    return -1;
    80005edc:	57fd                	li	a5,-1
    80005ede:	a03d                	j	80005f0c <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005ee0:	fc442783          	lw	a5,-60(s0)
    80005ee4:	0007c763          	bltz	a5,80005ef2 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005ee8:	07e9                	add	a5,a5,26
    80005eea:	078e                	sll	a5,a5,0x3
    80005eec:	97a6                	add	a5,a5,s1
    80005eee:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005ef2:	fd043503          	ld	a0,-48(s0)
    80005ef6:	fffff097          	auipc	ra,0xfffff
    80005efa:	9d4080e7          	jalr	-1580(ra) # 800048ca <fileclose>
    fileclose(wf);
    80005efe:	fc843503          	ld	a0,-56(s0)
    80005f02:	fffff097          	auipc	ra,0xfffff
    80005f06:	9c8080e7          	jalr	-1592(ra) # 800048ca <fileclose>
    return -1;
    80005f0a:	57fd                	li	a5,-1
}
    80005f0c:	853e                	mv	a0,a5
    80005f0e:	70e2                	ld	ra,56(sp)
    80005f10:	7442                	ld	s0,48(sp)
    80005f12:	74a2                	ld	s1,40(sp)
    80005f14:	6121                	add	sp,sp,64
    80005f16:	8082                	ret
	...

0000000080005f20 <kernelvec>:
    80005f20:	7111                	add	sp,sp,-256
    80005f22:	e006                	sd	ra,0(sp)
    80005f24:	e40a                	sd	sp,8(sp)
    80005f26:	e80e                	sd	gp,16(sp)
    80005f28:	ec12                	sd	tp,24(sp)
    80005f2a:	f016                	sd	t0,32(sp)
    80005f2c:	f41a                	sd	t1,40(sp)
    80005f2e:	f81e                	sd	t2,48(sp)
    80005f30:	fc22                	sd	s0,56(sp)
    80005f32:	e0a6                	sd	s1,64(sp)
    80005f34:	e4aa                	sd	a0,72(sp)
    80005f36:	e8ae                	sd	a1,80(sp)
    80005f38:	ecb2                	sd	a2,88(sp)
    80005f3a:	f0b6                	sd	a3,96(sp)
    80005f3c:	f4ba                	sd	a4,104(sp)
    80005f3e:	f8be                	sd	a5,112(sp)
    80005f40:	fcc2                	sd	a6,120(sp)
    80005f42:	e146                	sd	a7,128(sp)
    80005f44:	e54a                	sd	s2,136(sp)
    80005f46:	e94e                	sd	s3,144(sp)
    80005f48:	ed52                	sd	s4,152(sp)
    80005f4a:	f156                	sd	s5,160(sp)
    80005f4c:	f55a                	sd	s6,168(sp)
    80005f4e:	f95e                	sd	s7,176(sp)
    80005f50:	fd62                	sd	s8,184(sp)
    80005f52:	e1e6                	sd	s9,192(sp)
    80005f54:	e5ea                	sd	s10,200(sp)
    80005f56:	e9ee                	sd	s11,208(sp)
    80005f58:	edf2                	sd	t3,216(sp)
    80005f5a:	f1f6                	sd	t4,224(sp)
    80005f5c:	f5fa                	sd	t5,232(sp)
    80005f5e:	f9fe                	sd	t6,240(sp)
    80005f60:	c3dfc0ef          	jal	80002b9c <kerneltrap>
    80005f64:	6082                	ld	ra,0(sp)
    80005f66:	6122                	ld	sp,8(sp)
    80005f68:	61c2                	ld	gp,16(sp)
    80005f6a:	7282                	ld	t0,32(sp)
    80005f6c:	7322                	ld	t1,40(sp)
    80005f6e:	73c2                	ld	t2,48(sp)
    80005f70:	7462                	ld	s0,56(sp)
    80005f72:	6486                	ld	s1,64(sp)
    80005f74:	6526                	ld	a0,72(sp)
    80005f76:	65c6                	ld	a1,80(sp)
    80005f78:	6666                	ld	a2,88(sp)
    80005f7a:	7686                	ld	a3,96(sp)
    80005f7c:	7726                	ld	a4,104(sp)
    80005f7e:	77c6                	ld	a5,112(sp)
    80005f80:	7866                	ld	a6,120(sp)
    80005f82:	688a                	ld	a7,128(sp)
    80005f84:	692a                	ld	s2,136(sp)
    80005f86:	69ca                	ld	s3,144(sp)
    80005f88:	6a6a                	ld	s4,152(sp)
    80005f8a:	7a8a                	ld	s5,160(sp)
    80005f8c:	7b2a                	ld	s6,168(sp)
    80005f8e:	7bca                	ld	s7,176(sp)
    80005f90:	7c6a                	ld	s8,184(sp)
    80005f92:	6c8e                	ld	s9,192(sp)
    80005f94:	6d2e                	ld	s10,200(sp)
    80005f96:	6dce                	ld	s11,208(sp)
    80005f98:	6e6e                	ld	t3,216(sp)
    80005f9a:	7e8e                	ld	t4,224(sp)
    80005f9c:	7f2e                	ld	t5,232(sp)
    80005f9e:	7fce                	ld	t6,240(sp)
    80005fa0:	6111                	add	sp,sp,256
    80005fa2:	10200073          	sret
    80005fa6:	00000013          	nop
    80005faa:	00000013          	nop
    80005fae:	0001                	nop

0000000080005fb0 <timervec>:
    80005fb0:	34051573          	csrrw	a0,mscratch,a0
    80005fb4:	e10c                	sd	a1,0(a0)
    80005fb6:	e510                	sd	a2,8(a0)
    80005fb8:	e914                	sd	a3,16(a0)
    80005fba:	6d0c                	ld	a1,24(a0)
    80005fbc:	7110                	ld	a2,32(a0)
    80005fbe:	6194                	ld	a3,0(a1)
    80005fc0:	96b2                	add	a3,a3,a2
    80005fc2:	e194                	sd	a3,0(a1)
    80005fc4:	4589                	li	a1,2
    80005fc6:	14459073          	csrw	sip,a1
    80005fca:	6914                	ld	a3,16(a0)
    80005fcc:	6510                	ld	a2,8(a0)
    80005fce:	610c                	ld	a1,0(a0)
    80005fd0:	34051573          	csrrw	a0,mscratch,a0
    80005fd4:	30200073          	mret
	...

0000000080005fda <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005fda:	1141                	add	sp,sp,-16
    80005fdc:	e422                	sd	s0,8(sp)
    80005fde:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005fe0:	0c0007b7          	lui	a5,0xc000
    80005fe4:	4705                	li	a4,1
    80005fe6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005fe8:	c3d8                	sw	a4,4(a5)
}
    80005fea:	6422                	ld	s0,8(sp)
    80005fec:	0141                	add	sp,sp,16
    80005fee:	8082                	ret

0000000080005ff0 <plicinithart>:

void
plicinithart(void)
{
    80005ff0:	1141                	add	sp,sp,-16
    80005ff2:	e406                	sd	ra,8(sp)
    80005ff4:	e022                	sd	s0,0(sp)
    80005ff6:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005ff8:	ffffc097          	auipc	ra,0xffffc
    80005ffc:	982080e7          	jalr	-1662(ra) # 8000197a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006000:	0085171b          	sllw	a4,a0,0x8
    80006004:	0c0027b7          	lui	a5,0xc002
    80006008:	97ba                	add	a5,a5,a4
    8000600a:	40200713          	li	a4,1026
    8000600e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006012:	00d5151b          	sllw	a0,a0,0xd
    80006016:	0c2017b7          	lui	a5,0xc201
    8000601a:	97aa                	add	a5,a5,a0
    8000601c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006020:	60a2                	ld	ra,8(sp)
    80006022:	6402                	ld	s0,0(sp)
    80006024:	0141                	add	sp,sp,16
    80006026:	8082                	ret

0000000080006028 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006028:	1141                	add	sp,sp,-16
    8000602a:	e406                	sd	ra,8(sp)
    8000602c:	e022                	sd	s0,0(sp)
    8000602e:	0800                	add	s0,sp,16
  int hart = cpuid();
    80006030:	ffffc097          	auipc	ra,0xffffc
    80006034:	94a080e7          	jalr	-1718(ra) # 8000197a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006038:	00d5151b          	sllw	a0,a0,0xd
    8000603c:	0c2017b7          	lui	a5,0xc201
    80006040:	97aa                	add	a5,a5,a0
  return irq;
}
    80006042:	43c8                	lw	a0,4(a5)
    80006044:	60a2                	ld	ra,8(sp)
    80006046:	6402                	ld	s0,0(sp)
    80006048:	0141                	add	sp,sp,16
    8000604a:	8082                	ret

000000008000604c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000604c:	1101                	add	sp,sp,-32
    8000604e:	ec06                	sd	ra,24(sp)
    80006050:	e822                	sd	s0,16(sp)
    80006052:	e426                	sd	s1,8(sp)
    80006054:	1000                	add	s0,sp,32
    80006056:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006058:	ffffc097          	auipc	ra,0xffffc
    8000605c:	922080e7          	jalr	-1758(ra) # 8000197a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006060:	00d5151b          	sllw	a0,a0,0xd
    80006064:	0c2017b7          	lui	a5,0xc201
    80006068:	97aa                	add	a5,a5,a0
    8000606a:	c3c4                	sw	s1,4(a5)
}
    8000606c:	60e2                	ld	ra,24(sp)
    8000606e:	6442                	ld	s0,16(sp)
    80006070:	64a2                	ld	s1,8(sp)
    80006072:	6105                	add	sp,sp,32
    80006074:	8082                	ret

0000000080006076 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006076:	1141                	add	sp,sp,-16
    80006078:	e406                	sd	ra,8(sp)
    8000607a:	e022                	sd	s0,0(sp)
    8000607c:	0800                	add	s0,sp,16
  if(i >= NUM)
    8000607e:	479d                	li	a5,7
    80006080:	04a7cc63          	blt	a5,a0,800060d8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006084:	0001c797          	auipc	a5,0x1c
    80006088:	7e478793          	add	a5,a5,2020 # 80022868 <disk>
    8000608c:	97aa                	add	a5,a5,a0
    8000608e:	0187c783          	lbu	a5,24(a5)
    80006092:	ebb9                	bnez	a5,800060e8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006094:	00451693          	sll	a3,a0,0x4
    80006098:	0001c797          	auipc	a5,0x1c
    8000609c:	7d078793          	add	a5,a5,2000 # 80022868 <disk>
    800060a0:	6398                	ld	a4,0(a5)
    800060a2:	9736                	add	a4,a4,a3
    800060a4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800060a8:	6398                	ld	a4,0(a5)
    800060aa:	9736                	add	a4,a4,a3
    800060ac:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800060b0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800060b4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800060b8:	97aa                	add	a5,a5,a0
    800060ba:	4705                	li	a4,1
    800060bc:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800060c0:	0001c517          	auipc	a0,0x1c
    800060c4:	7c050513          	add	a0,a0,1984 # 80022880 <disk+0x18>
    800060c8:	ffffc097          	auipc	ra,0xffffc
    800060cc:	090080e7          	jalr	144(ra) # 80002158 <wakeup>
}
    800060d0:	60a2                	ld	ra,8(sp)
    800060d2:	6402                	ld	s0,0(sp)
    800060d4:	0141                	add	sp,sp,16
    800060d6:	8082                	ret
    panic("free_desc 1");
    800060d8:	00002517          	auipc	a0,0x2
    800060dc:	69850513          	add	a0,a0,1688 # 80008770 <syscalls+0x320>
    800060e0:	ffffa097          	auipc	ra,0xffffa
    800060e4:	45c080e7          	jalr	1116(ra) # 8000053c <panic>
    panic("free_desc 2");
    800060e8:	00002517          	auipc	a0,0x2
    800060ec:	69850513          	add	a0,a0,1688 # 80008780 <syscalls+0x330>
    800060f0:	ffffa097          	auipc	ra,0xffffa
    800060f4:	44c080e7          	jalr	1100(ra) # 8000053c <panic>

00000000800060f8 <virtio_disk_init>:
{
    800060f8:	1101                	add	sp,sp,-32
    800060fa:	ec06                	sd	ra,24(sp)
    800060fc:	e822                	sd	s0,16(sp)
    800060fe:	e426                	sd	s1,8(sp)
    80006100:	e04a                	sd	s2,0(sp)
    80006102:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006104:	00002597          	auipc	a1,0x2
    80006108:	68c58593          	add	a1,a1,1676 # 80008790 <syscalls+0x340>
    8000610c:	0001d517          	auipc	a0,0x1d
    80006110:	88450513          	add	a0,a0,-1916 # 80022990 <disk+0x128>
    80006114:	ffffb097          	auipc	ra,0xffffb
    80006118:	a2e080e7          	jalr	-1490(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000611c:	100017b7          	lui	a5,0x10001
    80006120:	4398                	lw	a4,0(a5)
    80006122:	2701                	sext.w	a4,a4
    80006124:	747277b7          	lui	a5,0x74727
    80006128:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000612c:	14f71b63          	bne	a4,a5,80006282 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006130:	100017b7          	lui	a5,0x10001
    80006134:	43dc                	lw	a5,4(a5)
    80006136:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006138:	4709                	li	a4,2
    8000613a:	14e79463          	bne	a5,a4,80006282 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000613e:	100017b7          	lui	a5,0x10001
    80006142:	479c                	lw	a5,8(a5)
    80006144:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006146:	12e79e63          	bne	a5,a4,80006282 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000614a:	100017b7          	lui	a5,0x10001
    8000614e:	47d8                	lw	a4,12(a5)
    80006150:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006152:	554d47b7          	lui	a5,0x554d4
    80006156:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000615a:	12f71463          	bne	a4,a5,80006282 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000615e:	100017b7          	lui	a5,0x10001
    80006162:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006166:	4705                	li	a4,1
    80006168:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000616a:	470d                	li	a4,3
    8000616c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000616e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006170:	c7ffe6b7          	lui	a3,0xc7ffe
    80006174:	75f68693          	add	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdbdb7>
    80006178:	8f75                	and	a4,a4,a3
    8000617a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000617c:	472d                	li	a4,11
    8000617e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006180:	5bbc                	lw	a5,112(a5)
    80006182:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006186:	8ba1                	and	a5,a5,8
    80006188:	10078563          	beqz	a5,80006292 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000618c:	100017b7          	lui	a5,0x10001
    80006190:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006194:	43fc                	lw	a5,68(a5)
    80006196:	2781                	sext.w	a5,a5
    80006198:	10079563          	bnez	a5,800062a2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000619c:	100017b7          	lui	a5,0x10001
    800061a0:	5bdc                	lw	a5,52(a5)
    800061a2:	2781                	sext.w	a5,a5
  if(max == 0)
    800061a4:	10078763          	beqz	a5,800062b2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    800061a8:	471d                	li	a4,7
    800061aa:	10f77c63          	bgeu	a4,a5,800062c2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    800061ae:	ffffb097          	auipc	ra,0xffffb
    800061b2:	934080e7          	jalr	-1740(ra) # 80000ae2 <kalloc>
    800061b6:	0001c497          	auipc	s1,0x1c
    800061ba:	6b248493          	add	s1,s1,1714 # 80022868 <disk>
    800061be:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800061c0:	ffffb097          	auipc	ra,0xffffb
    800061c4:	922080e7          	jalr	-1758(ra) # 80000ae2 <kalloc>
    800061c8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800061ca:	ffffb097          	auipc	ra,0xffffb
    800061ce:	918080e7          	jalr	-1768(ra) # 80000ae2 <kalloc>
    800061d2:	87aa                	mv	a5,a0
    800061d4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800061d6:	6088                	ld	a0,0(s1)
    800061d8:	cd6d                	beqz	a0,800062d2 <virtio_disk_init+0x1da>
    800061da:	0001c717          	auipc	a4,0x1c
    800061de:	69673703          	ld	a4,1686(a4) # 80022870 <disk+0x8>
    800061e2:	cb65                	beqz	a4,800062d2 <virtio_disk_init+0x1da>
    800061e4:	c7fd                	beqz	a5,800062d2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800061e6:	6605                	lui	a2,0x1
    800061e8:	4581                	li	a1,0
    800061ea:	ffffb097          	auipc	ra,0xffffb
    800061ee:	ae4080e7          	jalr	-1308(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    800061f2:	0001c497          	auipc	s1,0x1c
    800061f6:	67648493          	add	s1,s1,1654 # 80022868 <disk>
    800061fa:	6605                	lui	a2,0x1
    800061fc:	4581                	li	a1,0
    800061fe:	6488                	ld	a0,8(s1)
    80006200:	ffffb097          	auipc	ra,0xffffb
    80006204:	ace080e7          	jalr	-1330(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80006208:	6605                	lui	a2,0x1
    8000620a:	4581                	li	a1,0
    8000620c:	6888                	ld	a0,16(s1)
    8000620e:	ffffb097          	auipc	ra,0xffffb
    80006212:	ac0080e7          	jalr	-1344(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006216:	100017b7          	lui	a5,0x10001
    8000621a:	4721                	li	a4,8
    8000621c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000621e:	4098                	lw	a4,0(s1)
    80006220:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006224:	40d8                	lw	a4,4(s1)
    80006226:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000622a:	6498                	ld	a4,8(s1)
    8000622c:	0007069b          	sext.w	a3,a4
    80006230:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006234:	9701                	sra	a4,a4,0x20
    80006236:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000623a:	6898                	ld	a4,16(s1)
    8000623c:	0007069b          	sext.w	a3,a4
    80006240:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006244:	9701                	sra	a4,a4,0x20
    80006246:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000624a:	4705                	li	a4,1
    8000624c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000624e:	00e48c23          	sb	a4,24(s1)
    80006252:	00e48ca3          	sb	a4,25(s1)
    80006256:	00e48d23          	sb	a4,26(s1)
    8000625a:	00e48da3          	sb	a4,27(s1)
    8000625e:	00e48e23          	sb	a4,28(s1)
    80006262:	00e48ea3          	sb	a4,29(s1)
    80006266:	00e48f23          	sb	a4,30(s1)
    8000626a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000626e:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006272:	0727a823          	sw	s2,112(a5)
}
    80006276:	60e2                	ld	ra,24(sp)
    80006278:	6442                	ld	s0,16(sp)
    8000627a:	64a2                	ld	s1,8(sp)
    8000627c:	6902                	ld	s2,0(sp)
    8000627e:	6105                	add	sp,sp,32
    80006280:	8082                	ret
    panic("could not find virtio disk");
    80006282:	00002517          	auipc	a0,0x2
    80006286:	51e50513          	add	a0,a0,1310 # 800087a0 <syscalls+0x350>
    8000628a:	ffffa097          	auipc	ra,0xffffa
    8000628e:	2b2080e7          	jalr	690(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80006292:	00002517          	auipc	a0,0x2
    80006296:	52e50513          	add	a0,a0,1326 # 800087c0 <syscalls+0x370>
    8000629a:	ffffa097          	auipc	ra,0xffffa
    8000629e:	2a2080e7          	jalr	674(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    800062a2:	00002517          	auipc	a0,0x2
    800062a6:	53e50513          	add	a0,a0,1342 # 800087e0 <syscalls+0x390>
    800062aa:	ffffa097          	auipc	ra,0xffffa
    800062ae:	292080e7          	jalr	658(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    800062b2:	00002517          	auipc	a0,0x2
    800062b6:	54e50513          	add	a0,a0,1358 # 80008800 <syscalls+0x3b0>
    800062ba:	ffffa097          	auipc	ra,0xffffa
    800062be:	282080e7          	jalr	642(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    800062c2:	00002517          	auipc	a0,0x2
    800062c6:	55e50513          	add	a0,a0,1374 # 80008820 <syscalls+0x3d0>
    800062ca:	ffffa097          	auipc	ra,0xffffa
    800062ce:	272080e7          	jalr	626(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    800062d2:	00002517          	auipc	a0,0x2
    800062d6:	56e50513          	add	a0,a0,1390 # 80008840 <syscalls+0x3f0>
    800062da:	ffffa097          	auipc	ra,0xffffa
    800062de:	262080e7          	jalr	610(ra) # 8000053c <panic>

00000000800062e2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062e2:	7159                	add	sp,sp,-112
    800062e4:	f486                	sd	ra,104(sp)
    800062e6:	f0a2                	sd	s0,96(sp)
    800062e8:	eca6                	sd	s1,88(sp)
    800062ea:	e8ca                	sd	s2,80(sp)
    800062ec:	e4ce                	sd	s3,72(sp)
    800062ee:	e0d2                	sd	s4,64(sp)
    800062f0:	fc56                	sd	s5,56(sp)
    800062f2:	f85a                	sd	s6,48(sp)
    800062f4:	f45e                	sd	s7,40(sp)
    800062f6:	f062                	sd	s8,32(sp)
    800062f8:	ec66                	sd	s9,24(sp)
    800062fa:	e86a                	sd	s10,16(sp)
    800062fc:	1880                	add	s0,sp,112
    800062fe:	8a2a                	mv	s4,a0
    80006300:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006302:	00c52c83          	lw	s9,12(a0)
    80006306:	001c9c9b          	sllw	s9,s9,0x1
    8000630a:	1c82                	sll	s9,s9,0x20
    8000630c:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006310:	0001c517          	auipc	a0,0x1c
    80006314:	68050513          	add	a0,a0,1664 # 80022990 <disk+0x128>
    80006318:	ffffb097          	auipc	ra,0xffffb
    8000631c:	8ba080e7          	jalr	-1862(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006320:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006322:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006324:	0001cb17          	auipc	s6,0x1c
    80006328:	544b0b13          	add	s6,s6,1348 # 80022868 <disk>
  for(int i = 0; i < 3; i++){
    8000632c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000632e:	0001cc17          	auipc	s8,0x1c
    80006332:	662c0c13          	add	s8,s8,1634 # 80022990 <disk+0x128>
    80006336:	a095                	j	8000639a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006338:	00fb0733          	add	a4,s6,a5
    8000633c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006340:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006342:	0207c563          	bltz	a5,8000636c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006346:	2605                	addw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006348:	0591                	add	a1,a1,4
    8000634a:	05560d63          	beq	a2,s5,800063a4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000634e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006350:	0001c717          	auipc	a4,0x1c
    80006354:	51870713          	add	a4,a4,1304 # 80022868 <disk>
    80006358:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000635a:	01874683          	lbu	a3,24(a4)
    8000635e:	fee9                	bnez	a3,80006338 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006360:	2785                	addw	a5,a5,1
    80006362:	0705                	add	a4,a4,1
    80006364:	fe979be3          	bne	a5,s1,8000635a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006368:	57fd                	li	a5,-1
    8000636a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000636c:	00c05e63          	blez	a2,80006388 <virtio_disk_rw+0xa6>
    80006370:	060a                	sll	a2,a2,0x2
    80006372:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006376:	0009a503          	lw	a0,0(s3)
    8000637a:	00000097          	auipc	ra,0x0
    8000637e:	cfc080e7          	jalr	-772(ra) # 80006076 <free_desc>
      for(int j = 0; j < i; j++)
    80006382:	0991                	add	s3,s3,4
    80006384:	ffa999e3          	bne	s3,s10,80006376 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006388:	85e2                	mv	a1,s8
    8000638a:	0001c517          	auipc	a0,0x1c
    8000638e:	4f650513          	add	a0,a0,1270 # 80022880 <disk+0x18>
    80006392:	ffffc097          	auipc	ra,0xffffc
    80006396:	d62080e7          	jalr	-670(ra) # 800020f4 <sleep>
  for(int i = 0; i < 3; i++){
    8000639a:	f9040993          	add	s3,s0,-112
{
    8000639e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    800063a0:	864a                	mv	a2,s2
    800063a2:	b775                	j	8000634e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063a4:	f9042503          	lw	a0,-112(s0)
    800063a8:	00a50713          	add	a4,a0,10
    800063ac:	0712                	sll	a4,a4,0x4

  if(write)
    800063ae:	0001c797          	auipc	a5,0x1c
    800063b2:	4ba78793          	add	a5,a5,1210 # 80022868 <disk>
    800063b6:	00e786b3          	add	a3,a5,a4
    800063ba:	01703633          	snez	a2,s7
    800063be:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800063c0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800063c4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800063c8:	f6070613          	add	a2,a4,-160
    800063cc:	6394                	ld	a3,0(a5)
    800063ce:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800063d0:	00870593          	add	a1,a4,8
    800063d4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800063d6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800063d8:	0007b803          	ld	a6,0(a5)
    800063dc:	9642                	add	a2,a2,a6
    800063de:	46c1                	li	a3,16
    800063e0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063e2:	4585                	li	a1,1
    800063e4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800063e8:	f9442683          	lw	a3,-108(s0)
    800063ec:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063f0:	0692                	sll	a3,a3,0x4
    800063f2:	9836                	add	a6,a6,a3
    800063f4:	058a0613          	add	a2,s4,88
    800063f8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800063fc:	0007b803          	ld	a6,0(a5)
    80006400:	96c2                	add	a3,a3,a6
    80006402:	40000613          	li	a2,1024
    80006406:	c690                	sw	a2,8(a3)
  if(write)
    80006408:	001bb613          	seqz	a2,s7
    8000640c:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006410:	00166613          	or	a2,a2,1
    80006414:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006418:	f9842603          	lw	a2,-104(s0)
    8000641c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006420:	00250693          	add	a3,a0,2
    80006424:	0692                	sll	a3,a3,0x4
    80006426:	96be                	add	a3,a3,a5
    80006428:	58fd                	li	a7,-1
    8000642a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000642e:	0612                	sll	a2,a2,0x4
    80006430:	9832                	add	a6,a6,a2
    80006432:	f9070713          	add	a4,a4,-112
    80006436:	973e                	add	a4,a4,a5
    80006438:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000643c:	6398                	ld	a4,0(a5)
    8000643e:	9732                	add	a4,a4,a2
    80006440:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006442:	4609                	li	a2,2
    80006444:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006448:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000644c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006450:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006454:	6794                	ld	a3,8(a5)
    80006456:	0026d703          	lhu	a4,2(a3)
    8000645a:	8b1d                	and	a4,a4,7
    8000645c:	0706                	sll	a4,a4,0x1
    8000645e:	96ba                	add	a3,a3,a4
    80006460:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006464:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006468:	6798                	ld	a4,8(a5)
    8000646a:	00275783          	lhu	a5,2(a4)
    8000646e:	2785                	addw	a5,a5,1
    80006470:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006474:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006478:	100017b7          	lui	a5,0x10001
    8000647c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006480:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006484:	0001c917          	auipc	s2,0x1c
    80006488:	50c90913          	add	s2,s2,1292 # 80022990 <disk+0x128>
  while(b->disk == 1) {
    8000648c:	4485                	li	s1,1
    8000648e:	00b79c63          	bne	a5,a1,800064a6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006492:	85ca                	mv	a1,s2
    80006494:	8552                	mv	a0,s4
    80006496:	ffffc097          	auipc	ra,0xffffc
    8000649a:	c5e080e7          	jalr	-930(ra) # 800020f4 <sleep>
  while(b->disk == 1) {
    8000649e:	004a2783          	lw	a5,4(s4)
    800064a2:	fe9788e3          	beq	a5,s1,80006492 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800064a6:	f9042903          	lw	s2,-112(s0)
    800064aa:	00290713          	add	a4,s2,2
    800064ae:	0712                	sll	a4,a4,0x4
    800064b0:	0001c797          	auipc	a5,0x1c
    800064b4:	3b878793          	add	a5,a5,952 # 80022868 <disk>
    800064b8:	97ba                	add	a5,a5,a4
    800064ba:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800064be:	0001c997          	auipc	s3,0x1c
    800064c2:	3aa98993          	add	s3,s3,938 # 80022868 <disk>
    800064c6:	00491713          	sll	a4,s2,0x4
    800064ca:	0009b783          	ld	a5,0(s3)
    800064ce:	97ba                	add	a5,a5,a4
    800064d0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800064d4:	854a                	mv	a0,s2
    800064d6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800064da:	00000097          	auipc	ra,0x0
    800064de:	b9c080e7          	jalr	-1124(ra) # 80006076 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800064e2:	8885                	and	s1,s1,1
    800064e4:	f0ed                	bnez	s1,800064c6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800064e6:	0001c517          	auipc	a0,0x1c
    800064ea:	4aa50513          	add	a0,a0,1194 # 80022990 <disk+0x128>
    800064ee:	ffffa097          	auipc	ra,0xffffa
    800064f2:	798080e7          	jalr	1944(ra) # 80000c86 <release>
}
    800064f6:	70a6                	ld	ra,104(sp)
    800064f8:	7406                	ld	s0,96(sp)
    800064fa:	64e6                	ld	s1,88(sp)
    800064fc:	6946                	ld	s2,80(sp)
    800064fe:	69a6                	ld	s3,72(sp)
    80006500:	6a06                	ld	s4,64(sp)
    80006502:	7ae2                	ld	s5,56(sp)
    80006504:	7b42                	ld	s6,48(sp)
    80006506:	7ba2                	ld	s7,40(sp)
    80006508:	7c02                	ld	s8,32(sp)
    8000650a:	6ce2                	ld	s9,24(sp)
    8000650c:	6d42                	ld	s10,16(sp)
    8000650e:	6165                	add	sp,sp,112
    80006510:	8082                	ret

0000000080006512 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006512:	1101                	add	sp,sp,-32
    80006514:	ec06                	sd	ra,24(sp)
    80006516:	e822                	sd	s0,16(sp)
    80006518:	e426                	sd	s1,8(sp)
    8000651a:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000651c:	0001c497          	auipc	s1,0x1c
    80006520:	34c48493          	add	s1,s1,844 # 80022868 <disk>
    80006524:	0001c517          	auipc	a0,0x1c
    80006528:	46c50513          	add	a0,a0,1132 # 80022990 <disk+0x128>
    8000652c:	ffffa097          	auipc	ra,0xffffa
    80006530:	6a6080e7          	jalr	1702(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006534:	10001737          	lui	a4,0x10001
    80006538:	533c                	lw	a5,96(a4)
    8000653a:	8b8d                	and	a5,a5,3
    8000653c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000653e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006542:	689c                	ld	a5,16(s1)
    80006544:	0204d703          	lhu	a4,32(s1)
    80006548:	0027d783          	lhu	a5,2(a5)
    8000654c:	04f70863          	beq	a4,a5,8000659c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006550:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006554:	6898                	ld	a4,16(s1)
    80006556:	0204d783          	lhu	a5,32(s1)
    8000655a:	8b9d                	and	a5,a5,7
    8000655c:	078e                	sll	a5,a5,0x3
    8000655e:	97ba                	add	a5,a5,a4
    80006560:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006562:	00278713          	add	a4,a5,2
    80006566:	0712                	sll	a4,a4,0x4
    80006568:	9726                	add	a4,a4,s1
    8000656a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000656e:	e721                	bnez	a4,800065b6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006570:	0789                	add	a5,a5,2
    80006572:	0792                	sll	a5,a5,0x4
    80006574:	97a6                	add	a5,a5,s1
    80006576:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006578:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000657c:	ffffc097          	auipc	ra,0xffffc
    80006580:	bdc080e7          	jalr	-1060(ra) # 80002158 <wakeup>

    disk.used_idx += 1;
    80006584:	0204d783          	lhu	a5,32(s1)
    80006588:	2785                	addw	a5,a5,1
    8000658a:	17c2                	sll	a5,a5,0x30
    8000658c:	93c1                	srl	a5,a5,0x30
    8000658e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006592:	6898                	ld	a4,16(s1)
    80006594:	00275703          	lhu	a4,2(a4)
    80006598:	faf71ce3          	bne	a4,a5,80006550 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000659c:	0001c517          	auipc	a0,0x1c
    800065a0:	3f450513          	add	a0,a0,1012 # 80022990 <disk+0x128>
    800065a4:	ffffa097          	auipc	ra,0xffffa
    800065a8:	6e2080e7          	jalr	1762(ra) # 80000c86 <release>
}
    800065ac:	60e2                	ld	ra,24(sp)
    800065ae:	6442                	ld	s0,16(sp)
    800065b0:	64a2                	ld	s1,8(sp)
    800065b2:	6105                	add	sp,sp,32
    800065b4:	8082                	ret
      panic("virtio_disk_intr status");
    800065b6:	00002517          	auipc	a0,0x2
    800065ba:	2a250513          	add	a0,a0,674 # 80008858 <syscalls+0x408>
    800065be:	ffffa097          	auipc	ra,0xffffa
    800065c2:	f7e080e7          	jalr	-130(ra) # 8000053c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	sll	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	sll	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
