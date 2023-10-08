
user/_alarmtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <periodic>:
}

volatile static int count;

void periodic()
{
   0:	1141                	add	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	add	s0,sp,16
    count = count + 1;
   8:	00001797          	auipc	a5,0x1
   c:	ff87a783          	lw	a5,-8(a5) # 1000 <count>
  10:	2785                	addw	a5,a5,1
  12:	00001717          	auipc	a4,0x1
  16:	fef72723          	sw	a5,-18(a4) # 1000 <count>
    printf("alarm!\n");
  1a:	00001517          	auipc	a0,0x1
  1e:	bf650513          	add	a0,a0,-1034 # c10 <malloc+0xe6>
  22:	00001097          	auipc	ra,0x1
  26:	a50080e7          	jalr	-1456(ra) # a72 <printf>
    sigreturn();
  2a:	00000097          	auipc	ra,0x0
  2e:	778080e7          	jalr	1912(ra) # 7a2 <sigreturn>
}
  32:	60a2                	ld	ra,8(sp)
  34:	6402                	ld	s0,0(sp)
  36:	0141                	add	sp,sp,16
  38:	8082                	ret

000000000000003a <slow_handler>:
        printf("test2 passed\n");
    }
}

void slow_handler()
{
  3a:	1101                	add	sp,sp,-32
  3c:	ec06                	sd	ra,24(sp)
  3e:	e822                	sd	s0,16(sp)
  40:	e426                	sd	s1,8(sp)
  42:	1000                	add	s0,sp,32
    count++;
  44:	00001497          	auipc	s1,0x1
  48:	fbc48493          	add	s1,s1,-68 # 1000 <count>
  4c:	00001797          	auipc	a5,0x1
  50:	fb47a783          	lw	a5,-76(a5) # 1000 <count>
  54:	2785                	addw	a5,a5,1
  56:	c09c                	sw	a5,0(s1)
    printf("alarm!\n");
  58:	00001517          	auipc	a0,0x1
  5c:	bb850513          	add	a0,a0,-1096 # c10 <malloc+0xe6>
  60:	00001097          	auipc	ra,0x1
  64:	a12080e7          	jalr	-1518(ra) # a72 <printf>
    if (count > 1)
  68:	4098                	lw	a4,0(s1)
  6a:	2701                	sext.w	a4,a4
  6c:	4685                	li	a3,1
  6e:	1dcd67b7          	lui	a5,0x1dcd6
  72:	50078793          	add	a5,a5,1280 # 1dcd6500 <base+0x1dcd54f0>
  76:	02e6c463          	blt	a3,a4,9e <slow_handler+0x64>
        printf("test2 failed: alarm handler called more than once\n");
        exit(1);
    }
    for (int i = 0; i < 1000 * 500000; i++)
    {
        asm volatile("nop"); // avoid compiler optimizing away loop
  7a:	0001                	nop
    for (int i = 0; i < 1000 * 500000; i++)
  7c:	37fd                	addw	a5,a5,-1
  7e:	fff5                	bnez	a5,7a <slow_handler+0x40>
    }
    sigalarm(0, 0);
  80:	4581                	li	a1,0
  82:	4501                	li	a0,0
  84:	00000097          	auipc	ra,0x0
  88:	716080e7          	jalr	1814(ra) # 79a <sigalarm>
    sigreturn();
  8c:	00000097          	auipc	ra,0x0
  90:	716080e7          	jalr	1814(ra) # 7a2 <sigreturn>
}
  94:	60e2                	ld	ra,24(sp)
  96:	6442                	ld	s0,16(sp)
  98:	64a2                	ld	s1,8(sp)
  9a:	6105                	add	sp,sp,32
  9c:	8082                	ret
        printf("test2 failed: alarm handler called more than once\n");
  9e:	00001517          	auipc	a0,0x1
  a2:	b7a50513          	add	a0,a0,-1158 # c18 <malloc+0xee>
  a6:	00001097          	auipc	ra,0x1
  aa:	9cc080e7          	jalr	-1588(ra) # a72 <printf>
        exit(1);
  ae:	4505                	li	a0,1
  b0:	00000097          	auipc	ra,0x0
  b4:	63a080e7          	jalr	1594(ra) # 6ea <exit>

00000000000000b8 <dummy_handler>:

//
// dummy alarm handler; after running immediately uninstall
// itself and finish signal handling
void dummy_handler()
{
  b8:	1141                	add	sp,sp,-16
  ba:	e406                	sd	ra,8(sp)
  bc:	e022                	sd	s0,0(sp)
  be:	0800                	add	s0,sp,16
    sigalarm(0, 0);
  c0:	4581                	li	a1,0
  c2:	4501                	li	a0,0
  c4:	00000097          	auipc	ra,0x0
  c8:	6d6080e7          	jalr	1750(ra) # 79a <sigalarm>
    sigreturn();
  cc:	00000097          	auipc	ra,0x0
  d0:	6d6080e7          	jalr	1750(ra) # 7a2 <sigreturn>
}
  d4:	60a2                	ld	ra,8(sp)
  d6:	6402                	ld	s0,0(sp)
  d8:	0141                	add	sp,sp,16
  da:	8082                	ret

00000000000000dc <test0>:
{
  dc:	7139                	add	sp,sp,-64
  de:	fc06                	sd	ra,56(sp)
  e0:	f822                	sd	s0,48(sp)
  e2:	f426                	sd	s1,40(sp)
  e4:	f04a                	sd	s2,32(sp)
  e6:	ec4e                	sd	s3,24(sp)
  e8:	e852                	sd	s4,16(sp)
  ea:	e456                	sd	s5,8(sp)
  ec:	0080                	add	s0,sp,64
    printf("test0 start\n");
  ee:	00001517          	auipc	a0,0x1
  f2:	b6250513          	add	a0,a0,-1182 # c50 <malloc+0x126>
  f6:	00001097          	auipc	ra,0x1
  fa:	97c080e7          	jalr	-1668(ra) # a72 <printf>
    count = 0;
  fe:	00001797          	auipc	a5,0x1
 102:	f007a123          	sw	zero,-254(a5) # 1000 <count>
    sigalarm(2, periodic);
 106:	00000597          	auipc	a1,0x0
 10a:	efa58593          	add	a1,a1,-262 # 0 <periodic>
 10e:	4509                	li	a0,2
 110:	00000097          	auipc	ra,0x0
 114:	68a080e7          	jalr	1674(ra) # 79a <sigalarm>
    for (i = 0; i < 1000 * 500000; i++)
 118:	4481                	li	s1,0
        if ((i % 1000000) == 0)
 11a:	000f4937          	lui	s2,0xf4
 11e:	2409091b          	addw	s2,s2,576 # f4240 <base+0xf3230>
            write(2, ".", 1);
 122:	00001a97          	auipc	s5,0x1
 126:	b3ea8a93          	add	s5,s5,-1218 # c60 <malloc+0x136>
        if (count > 0)
 12a:	00001a17          	auipc	s4,0x1
 12e:	ed6a0a13          	add	s4,s4,-298 # 1000 <count>
    for (i = 0; i < 1000 * 500000; i++)
 132:	1dcd69b7          	lui	s3,0x1dcd6
 136:	50098993          	add	s3,s3,1280 # 1dcd6500 <base+0x1dcd54f0>
 13a:	a809                	j	14c <test0+0x70>
        if (count > 0)
 13c:	000a2783          	lw	a5,0(s4)
 140:	2781                	sext.w	a5,a5
 142:	02f04063          	bgtz	a5,162 <test0+0x86>
    for (i = 0; i < 1000 * 500000; i++)
 146:	2485                	addw	s1,s1,1
 148:	01348d63          	beq	s1,s3,162 <test0+0x86>
        if ((i % 1000000) == 0)
 14c:	0324e7bb          	remw	a5,s1,s2
 150:	f7f5                	bnez	a5,13c <test0+0x60>
            write(2, ".", 1);
 152:	4605                	li	a2,1
 154:	85d6                	mv	a1,s5
 156:	4509                	li	a0,2
 158:	00000097          	auipc	ra,0x0
 15c:	5b2080e7          	jalr	1458(ra) # 70a <write>
 160:	bff1                	j	13c <test0+0x60>
    sigalarm(0, 0);
 162:	4581                	li	a1,0
 164:	4501                	li	a0,0
 166:	00000097          	auipc	ra,0x0
 16a:	634080e7          	jalr	1588(ra) # 79a <sigalarm>
    if (count > 0)
 16e:	00001797          	auipc	a5,0x1
 172:	e927a783          	lw	a5,-366(a5) # 1000 <count>
 176:	02f05363          	blez	a5,19c <test0+0xc0>
        printf("test0 passed\n");
 17a:	00001517          	auipc	a0,0x1
 17e:	aee50513          	add	a0,a0,-1298 # c68 <malloc+0x13e>
 182:	00001097          	auipc	ra,0x1
 186:	8f0080e7          	jalr	-1808(ra) # a72 <printf>
}
 18a:	70e2                	ld	ra,56(sp)
 18c:	7442                	ld	s0,48(sp)
 18e:	74a2                	ld	s1,40(sp)
 190:	7902                	ld	s2,32(sp)
 192:	69e2                	ld	s3,24(sp)
 194:	6a42                	ld	s4,16(sp)
 196:	6aa2                	ld	s5,8(sp)
 198:	6121                	add	sp,sp,64
 19a:	8082                	ret
        printf("\ntest0 failed: the kernel never called the alarm handler\n");
 19c:	00001517          	auipc	a0,0x1
 1a0:	adc50513          	add	a0,a0,-1316 # c78 <malloc+0x14e>
 1a4:	00001097          	auipc	ra,0x1
 1a8:	8ce080e7          	jalr	-1842(ra) # a72 <printf>
}
 1ac:	bff9                	j	18a <test0+0xae>

00000000000001ae <foo>:
{
 1ae:	1101                	add	sp,sp,-32
 1b0:	ec06                	sd	ra,24(sp)
 1b2:	e822                	sd	s0,16(sp)
 1b4:	e426                	sd	s1,8(sp)
 1b6:	1000                	add	s0,sp,32
 1b8:	84ae                	mv	s1,a1
    if ((i % 2500000) == 0)
 1ba:	002627b7          	lui	a5,0x262
 1be:	5a07879b          	addw	a5,a5,1440 # 2625a0 <base+0x261590>
 1c2:	02f5653b          	remw	a0,a0,a5
 1c6:	c909                	beqz	a0,1d8 <foo+0x2a>
    *j += 1;
 1c8:	409c                	lw	a5,0(s1)
 1ca:	2785                	addw	a5,a5,1
 1cc:	c09c                	sw	a5,0(s1)
}
 1ce:	60e2                	ld	ra,24(sp)
 1d0:	6442                	ld	s0,16(sp)
 1d2:	64a2                	ld	s1,8(sp)
 1d4:	6105                	add	sp,sp,32
 1d6:	8082                	ret
        write(2, ".", 1);
 1d8:	4605                	li	a2,1
 1da:	00001597          	auipc	a1,0x1
 1de:	a8658593          	add	a1,a1,-1402 # c60 <malloc+0x136>
 1e2:	4509                	li	a0,2
 1e4:	00000097          	auipc	ra,0x0
 1e8:	526080e7          	jalr	1318(ra) # 70a <write>
 1ec:	bff1                	j	1c8 <foo+0x1a>

00000000000001ee <test1>:
{
 1ee:	7139                	add	sp,sp,-64
 1f0:	fc06                	sd	ra,56(sp)
 1f2:	f822                	sd	s0,48(sp)
 1f4:	f426                	sd	s1,40(sp)
 1f6:	f04a                	sd	s2,32(sp)
 1f8:	ec4e                	sd	s3,24(sp)
 1fa:	e852                	sd	s4,16(sp)
 1fc:	0080                	add	s0,sp,64
    printf("test1 start\n");
 1fe:	00001517          	auipc	a0,0x1
 202:	aba50513          	add	a0,a0,-1350 # cb8 <malloc+0x18e>
 206:	00001097          	auipc	ra,0x1
 20a:	86c080e7          	jalr	-1940(ra) # a72 <printf>
    count = 0;
 20e:	00001797          	auipc	a5,0x1
 212:	de07a923          	sw	zero,-526(a5) # 1000 <count>
    j = 0;
 216:	fc042623          	sw	zero,-52(s0)
    sigalarm(2, periodic);
 21a:	00000597          	auipc	a1,0x0
 21e:	de658593          	add	a1,a1,-538 # 0 <periodic>
 222:	4509                	li	a0,2
 224:	00000097          	auipc	ra,0x0
 228:	576080e7          	jalr	1398(ra) # 79a <sigalarm>
    for (i = 0; i < 500000000; i++)
 22c:	4481                	li	s1,0
        if (count >= 10)
 22e:	00001a17          	auipc	s4,0x1
 232:	dd2a0a13          	add	s4,s4,-558 # 1000 <count>
 236:	49a5                	li	s3,9
    for (i = 0; i < 500000000; i++)
 238:	1dcd6937          	lui	s2,0x1dcd6
 23c:	50090913          	add	s2,s2,1280 # 1dcd6500 <base+0x1dcd54f0>
        if (count >= 10)
 240:	000a2783          	lw	a5,0(s4)
 244:	2781                	sext.w	a5,a5
 246:	00f9cc63          	blt	s3,a5,25e <test1+0x70>
        foo(i, &j);
 24a:	fcc40593          	add	a1,s0,-52
 24e:	8526                	mv	a0,s1
 250:	00000097          	auipc	ra,0x0
 254:	f5e080e7          	jalr	-162(ra) # 1ae <foo>
    for (i = 0; i < 500000000; i++)
 258:	2485                	addw	s1,s1,1
 25a:	ff2493e3          	bne	s1,s2,240 <test1+0x52>
    if (count < 10)
 25e:	00001717          	auipc	a4,0x1
 262:	da272703          	lw	a4,-606(a4) # 1000 <count>
 266:	47a5                	li	a5,9
 268:	02e7d663          	bge	a5,a4,294 <test1+0xa6>
    else if (i != j)
 26c:	fcc42783          	lw	a5,-52(s0)
 270:	02978b63          	beq	a5,s1,2a6 <test1+0xb8>
        printf("\ntest1 failed: foo() executed fewer times than it was called\n");
 274:	00001517          	auipc	a0,0x1
 278:	a8450513          	add	a0,a0,-1404 # cf8 <malloc+0x1ce>
 27c:	00000097          	auipc	ra,0x0
 280:	7f6080e7          	jalr	2038(ra) # a72 <printf>
}
 284:	70e2                	ld	ra,56(sp)
 286:	7442                	ld	s0,48(sp)
 288:	74a2                	ld	s1,40(sp)
 28a:	7902                	ld	s2,32(sp)
 28c:	69e2                	ld	s3,24(sp)
 28e:	6a42                	ld	s4,16(sp)
 290:	6121                	add	sp,sp,64
 292:	8082                	ret
        printf("\ntest1 failed: too few calls to the handler\n");
 294:	00001517          	auipc	a0,0x1
 298:	a3450513          	add	a0,a0,-1484 # cc8 <malloc+0x19e>
 29c:	00000097          	auipc	ra,0x0
 2a0:	7d6080e7          	jalr	2006(ra) # a72 <printf>
 2a4:	b7c5                	j	284 <test1+0x96>
        printf("test1 passed\n");
 2a6:	00001517          	auipc	a0,0x1
 2aa:	a9250513          	add	a0,a0,-1390 # d38 <malloc+0x20e>
 2ae:	00000097          	auipc	ra,0x0
 2b2:	7c4080e7          	jalr	1988(ra) # a72 <printf>
}
 2b6:	b7f9                	j	284 <test1+0x96>

00000000000002b8 <test2>:
{
 2b8:	715d                	add	sp,sp,-80
 2ba:	e486                	sd	ra,72(sp)
 2bc:	e0a2                	sd	s0,64(sp)
 2be:	fc26                	sd	s1,56(sp)
 2c0:	f84a                	sd	s2,48(sp)
 2c2:	f44e                	sd	s3,40(sp)
 2c4:	f052                	sd	s4,32(sp)
 2c6:	ec56                	sd	s5,24(sp)
 2c8:	0880                	add	s0,sp,80
    printf("test2 start\n");
 2ca:	00001517          	auipc	a0,0x1
 2ce:	a7e50513          	add	a0,a0,-1410 # d48 <malloc+0x21e>
 2d2:	00000097          	auipc	ra,0x0
 2d6:	7a0080e7          	jalr	1952(ra) # a72 <printf>
    if ((pid = fork()) < 0)
 2da:	00000097          	auipc	ra,0x0
 2de:	408080e7          	jalr	1032(ra) # 6e2 <fork>
 2e2:	04054263          	bltz	a0,326 <test2+0x6e>
 2e6:	84aa                	mv	s1,a0
    if (pid == 0)
 2e8:	e539                	bnez	a0,336 <test2+0x7e>
        count = 0;
 2ea:	00001797          	auipc	a5,0x1
 2ee:	d007ab23          	sw	zero,-746(a5) # 1000 <count>
        sigalarm(2, slow_handler);
 2f2:	00000597          	auipc	a1,0x0
 2f6:	d4858593          	add	a1,a1,-696 # 3a <slow_handler>
 2fa:	4509                	li	a0,2
 2fc:	00000097          	auipc	ra,0x0
 300:	49e080e7          	jalr	1182(ra) # 79a <sigalarm>
            if ((i % 1000000) == 0)
 304:	000f4937          	lui	s2,0xf4
 308:	2409091b          	addw	s2,s2,576 # f4240 <base+0xf3230>
                write(2, ".", 1);
 30c:	00001a97          	auipc	s5,0x1
 310:	954a8a93          	add	s5,s5,-1708 # c60 <malloc+0x136>
            if (count > 0)
 314:	00001a17          	auipc	s4,0x1
 318:	ceca0a13          	add	s4,s4,-788 # 1000 <count>
        for (i = 0; i < 1000 * 500000; i++)
 31c:	1dcd69b7          	lui	s3,0x1dcd6
 320:	50098993          	add	s3,s3,1280 # 1dcd6500 <base+0x1dcd54f0>
 324:	a099                	j	36a <test2+0xb2>
        printf("test2: fork failed\n");
 326:	00001517          	auipc	a0,0x1
 32a:	a3250513          	add	a0,a0,-1486 # d58 <malloc+0x22e>
 32e:	00000097          	auipc	ra,0x0
 332:	744080e7          	jalr	1860(ra) # a72 <printf>
    wait(&status);
 336:	fbc40513          	add	a0,s0,-68
 33a:	00000097          	auipc	ra,0x0
 33e:	3b8080e7          	jalr	952(ra) # 6f2 <wait>
    if (status == 0)
 342:	fbc42783          	lw	a5,-68(s0)
 346:	c7a5                	beqz	a5,3ae <test2+0xf6>
}
 348:	60a6                	ld	ra,72(sp)
 34a:	6406                	ld	s0,64(sp)
 34c:	74e2                	ld	s1,56(sp)
 34e:	7942                	ld	s2,48(sp)
 350:	79a2                	ld	s3,40(sp)
 352:	7a02                	ld	s4,32(sp)
 354:	6ae2                	ld	s5,24(sp)
 356:	6161                	add	sp,sp,80
 358:	8082                	ret
            if (count > 0)
 35a:	000a2783          	lw	a5,0(s4)
 35e:	2781                	sext.w	a5,a5
 360:	02f04063          	bgtz	a5,380 <test2+0xc8>
        for (i = 0; i < 1000 * 500000; i++)
 364:	2485                	addw	s1,s1,1
 366:	01348d63          	beq	s1,s3,380 <test2+0xc8>
            if ((i % 1000000) == 0)
 36a:	0324e7bb          	remw	a5,s1,s2
 36e:	f7f5                	bnez	a5,35a <test2+0xa2>
                write(2, ".", 1);
 370:	4605                	li	a2,1
 372:	85d6                	mv	a1,s5
 374:	4509                	li	a0,2
 376:	00000097          	auipc	ra,0x0
 37a:	394080e7          	jalr	916(ra) # 70a <write>
 37e:	bff1                	j	35a <test2+0xa2>
        if (count == 0)
 380:	00001797          	auipc	a5,0x1
 384:	c807a783          	lw	a5,-896(a5) # 1000 <count>
 388:	ef91                	bnez	a5,3a4 <test2+0xec>
            printf("\ntest2 failed: alarm not called\n");
 38a:	00001517          	auipc	a0,0x1
 38e:	9e650513          	add	a0,a0,-1562 # d70 <malloc+0x246>
 392:	00000097          	auipc	ra,0x0
 396:	6e0080e7          	jalr	1760(ra) # a72 <printf>
            exit(1);
 39a:	4505                	li	a0,1
 39c:	00000097          	auipc	ra,0x0
 3a0:	34e080e7          	jalr	846(ra) # 6ea <exit>
        exit(0);
 3a4:	4501                	li	a0,0
 3a6:	00000097          	auipc	ra,0x0
 3aa:	344080e7          	jalr	836(ra) # 6ea <exit>
        printf("test2 passed\n");
 3ae:	00001517          	auipc	a0,0x1
 3b2:	9ea50513          	add	a0,a0,-1558 # d98 <malloc+0x26e>
 3b6:	00000097          	auipc	ra,0x0
 3ba:	6bc080e7          	jalr	1724(ra) # a72 <printf>
}
 3be:	b769                	j	348 <test2+0x90>

00000000000003c0 <test3>:

//
// tests that the return from sys_sigreturn() does not
// modify the a0 register
void test3()
{
 3c0:	1141                	add	sp,sp,-16
 3c2:	e406                	sd	ra,8(sp)
 3c4:	e022                	sd	s0,0(sp)
 3c6:	0800                	add	s0,sp,16
    uint64 a0;

    sigalarm(1, dummy_handler);
 3c8:	00000597          	auipc	a1,0x0
 3cc:	cf058593          	add	a1,a1,-784 # b8 <dummy_handler>
 3d0:	4505                	li	a0,1
 3d2:	00000097          	auipc	ra,0x0
 3d6:	3c8080e7          	jalr	968(ra) # 79a <sigalarm>
    printf("test3 start\n");
 3da:	00001517          	auipc	a0,0x1
 3de:	9ce50513          	add	a0,a0,-1586 # da8 <malloc+0x27e>
 3e2:	00000097          	auipc	ra,0x0
 3e6:	690080e7          	jalr	1680(ra) # a72 <printf>

    asm volatile("lui a5, 0");
 3ea:	000007b7          	lui	a5,0x0
    asm volatile("addi a0, a5, 0xac" : : : "a0");
 3ee:	0ac78513          	add	a0,a5,172 # ac <slow_handler+0x72>
 3f2:	1dcd67b7          	lui	a5,0x1dcd6
 3f6:	50078793          	add	a5,a5,1280 # 1dcd6500 <base+0x1dcd54f0>
    for (int i = 0; i < 500000000; i++)
 3fa:	37fd                	addw	a5,a5,-1
 3fc:	fffd                	bnez	a5,3fa <test3+0x3a>
        ;
    asm volatile("mv %0, a0" : "=r"(a0));
 3fe:	872a                	mv	a4,a0

    if (a0 != 0xac)
 400:	0ac00793          	li	a5,172
 404:	00f70e63          	beq	a4,a5,420 <test3+0x60>
        printf("test3 failed: register a0 changed\n");
 408:	00001517          	auipc	a0,0x1
 40c:	9b050513          	add	a0,a0,-1616 # db8 <malloc+0x28e>
 410:	00000097          	auipc	ra,0x0
 414:	662080e7          	jalr	1634(ra) # a72 <printf>
    else
        printf("test3 passed\n");
 418:	60a2                	ld	ra,8(sp)
 41a:	6402                	ld	s0,0(sp)
 41c:	0141                	add	sp,sp,16
 41e:	8082                	ret
        printf("test3 passed\n");
 420:	00001517          	auipc	a0,0x1
 424:	9c050513          	add	a0,a0,-1600 # de0 <malloc+0x2b6>
 428:	00000097          	auipc	ra,0x0
 42c:	64a080e7          	jalr	1610(ra) # a72 <printf>
 430:	b7e5                	j	418 <test3+0x58>

0000000000000432 <main>:
{
 432:	1141                	add	sp,sp,-16
 434:	e406                	sd	ra,8(sp)
 436:	e022                	sd	s0,0(sp)
 438:	0800                	add	s0,sp,16
    test0();
 43a:	00000097          	auipc	ra,0x0
 43e:	ca2080e7          	jalr	-862(ra) # dc <test0>
    test1();
 442:	00000097          	auipc	ra,0x0
 446:	dac080e7          	jalr	-596(ra) # 1ee <test1>
    test2();
 44a:	00000097          	auipc	ra,0x0
 44e:	e6e080e7          	jalr	-402(ra) # 2b8 <test2>
    test3();
 452:	00000097          	auipc	ra,0x0
 456:	f6e080e7          	jalr	-146(ra) # 3c0 <test3>
    exit(0);
 45a:	4501                	li	a0,0
 45c:	00000097          	auipc	ra,0x0
 460:	28e080e7          	jalr	654(ra) # 6ea <exit>

0000000000000464 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 464:	1141                	add	sp,sp,-16
 466:	e406                	sd	ra,8(sp)
 468:	e022                	sd	s0,0(sp)
 46a:	0800                	add	s0,sp,16
  extern int main();
  main();
 46c:	00000097          	auipc	ra,0x0
 470:	fc6080e7          	jalr	-58(ra) # 432 <main>
  exit(0);
 474:	4501                	li	a0,0
 476:	00000097          	auipc	ra,0x0
 47a:	274080e7          	jalr	628(ra) # 6ea <exit>

000000000000047e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 47e:	1141                	add	sp,sp,-16
 480:	e422                	sd	s0,8(sp)
 482:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 484:	87aa                	mv	a5,a0
 486:	0585                	add	a1,a1,1
 488:	0785                	add	a5,a5,1
 48a:	fff5c703          	lbu	a4,-1(a1)
 48e:	fee78fa3          	sb	a4,-1(a5)
 492:	fb75                	bnez	a4,486 <strcpy+0x8>
    ;
  return os;
}
 494:	6422                	ld	s0,8(sp)
 496:	0141                	add	sp,sp,16
 498:	8082                	ret

000000000000049a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 49a:	1141                	add	sp,sp,-16
 49c:	e422                	sd	s0,8(sp)
 49e:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 4a0:	00054783          	lbu	a5,0(a0)
 4a4:	cb91                	beqz	a5,4b8 <strcmp+0x1e>
 4a6:	0005c703          	lbu	a4,0(a1)
 4aa:	00f71763          	bne	a4,a5,4b8 <strcmp+0x1e>
    p++, q++;
 4ae:	0505                	add	a0,a0,1
 4b0:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 4b2:	00054783          	lbu	a5,0(a0)
 4b6:	fbe5                	bnez	a5,4a6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4b8:	0005c503          	lbu	a0,0(a1)
}
 4bc:	40a7853b          	subw	a0,a5,a0
 4c0:	6422                	ld	s0,8(sp)
 4c2:	0141                	add	sp,sp,16
 4c4:	8082                	ret

00000000000004c6 <strlen>:

uint
strlen(const char *s)
{
 4c6:	1141                	add	sp,sp,-16
 4c8:	e422                	sd	s0,8(sp)
 4ca:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 4cc:	00054783          	lbu	a5,0(a0)
 4d0:	cf91                	beqz	a5,4ec <strlen+0x26>
 4d2:	0505                	add	a0,a0,1
 4d4:	87aa                	mv	a5,a0
 4d6:	86be                	mv	a3,a5
 4d8:	0785                	add	a5,a5,1
 4da:	fff7c703          	lbu	a4,-1(a5)
 4de:	ff65                	bnez	a4,4d6 <strlen+0x10>
 4e0:	40a6853b          	subw	a0,a3,a0
 4e4:	2505                	addw	a0,a0,1
    ;
  return n;
}
 4e6:	6422                	ld	s0,8(sp)
 4e8:	0141                	add	sp,sp,16
 4ea:	8082                	ret
  for(n = 0; s[n]; n++)
 4ec:	4501                	li	a0,0
 4ee:	bfe5                	j	4e6 <strlen+0x20>

00000000000004f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 4f0:	1141                	add	sp,sp,-16
 4f2:	e422                	sd	s0,8(sp)
 4f4:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 4f6:	ca19                	beqz	a2,50c <memset+0x1c>
 4f8:	87aa                	mv	a5,a0
 4fa:	1602                	sll	a2,a2,0x20
 4fc:	9201                	srl	a2,a2,0x20
 4fe:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 502:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 506:	0785                	add	a5,a5,1
 508:	fee79de3          	bne	a5,a4,502 <memset+0x12>
  }
  return dst;
}
 50c:	6422                	ld	s0,8(sp)
 50e:	0141                	add	sp,sp,16
 510:	8082                	ret

0000000000000512 <strchr>:

char*
strchr(const char *s, char c)
{
 512:	1141                	add	sp,sp,-16
 514:	e422                	sd	s0,8(sp)
 516:	0800                	add	s0,sp,16
  for(; *s; s++)
 518:	00054783          	lbu	a5,0(a0)
 51c:	cb99                	beqz	a5,532 <strchr+0x20>
    if(*s == c)
 51e:	00f58763          	beq	a1,a5,52c <strchr+0x1a>
  for(; *s; s++)
 522:	0505                	add	a0,a0,1
 524:	00054783          	lbu	a5,0(a0)
 528:	fbfd                	bnez	a5,51e <strchr+0xc>
      return (char*)s;
  return 0;
 52a:	4501                	li	a0,0
}
 52c:	6422                	ld	s0,8(sp)
 52e:	0141                	add	sp,sp,16
 530:	8082                	ret
  return 0;
 532:	4501                	li	a0,0
 534:	bfe5                	j	52c <strchr+0x1a>

0000000000000536 <gets>:

char*
gets(char *buf, int max)
{
 536:	711d                	add	sp,sp,-96
 538:	ec86                	sd	ra,88(sp)
 53a:	e8a2                	sd	s0,80(sp)
 53c:	e4a6                	sd	s1,72(sp)
 53e:	e0ca                	sd	s2,64(sp)
 540:	fc4e                	sd	s3,56(sp)
 542:	f852                	sd	s4,48(sp)
 544:	f456                	sd	s5,40(sp)
 546:	f05a                	sd	s6,32(sp)
 548:	ec5e                	sd	s7,24(sp)
 54a:	1080                	add	s0,sp,96
 54c:	8baa                	mv	s7,a0
 54e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 550:	892a                	mv	s2,a0
 552:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 554:	4aa9                	li	s5,10
 556:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 558:	89a6                	mv	s3,s1
 55a:	2485                	addw	s1,s1,1
 55c:	0344d863          	bge	s1,s4,58c <gets+0x56>
    cc = read(0, &c, 1);
 560:	4605                	li	a2,1
 562:	faf40593          	add	a1,s0,-81
 566:	4501                	li	a0,0
 568:	00000097          	auipc	ra,0x0
 56c:	19a080e7          	jalr	410(ra) # 702 <read>
    if(cc < 1)
 570:	00a05e63          	blez	a0,58c <gets+0x56>
    buf[i++] = c;
 574:	faf44783          	lbu	a5,-81(s0)
 578:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 57c:	01578763          	beq	a5,s5,58a <gets+0x54>
 580:	0905                	add	s2,s2,1
 582:	fd679be3          	bne	a5,s6,558 <gets+0x22>
  for(i=0; i+1 < max; ){
 586:	89a6                	mv	s3,s1
 588:	a011                	j	58c <gets+0x56>
 58a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 58c:	99de                	add	s3,s3,s7
 58e:	00098023          	sb	zero,0(s3)
  return buf;
}
 592:	855e                	mv	a0,s7
 594:	60e6                	ld	ra,88(sp)
 596:	6446                	ld	s0,80(sp)
 598:	64a6                	ld	s1,72(sp)
 59a:	6906                	ld	s2,64(sp)
 59c:	79e2                	ld	s3,56(sp)
 59e:	7a42                	ld	s4,48(sp)
 5a0:	7aa2                	ld	s5,40(sp)
 5a2:	7b02                	ld	s6,32(sp)
 5a4:	6be2                	ld	s7,24(sp)
 5a6:	6125                	add	sp,sp,96
 5a8:	8082                	ret

00000000000005aa <stat>:

int
stat(const char *n, struct stat *st)
{
 5aa:	1101                	add	sp,sp,-32
 5ac:	ec06                	sd	ra,24(sp)
 5ae:	e822                	sd	s0,16(sp)
 5b0:	e426                	sd	s1,8(sp)
 5b2:	e04a                	sd	s2,0(sp)
 5b4:	1000                	add	s0,sp,32
 5b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5b8:	4581                	li	a1,0
 5ba:	00000097          	auipc	ra,0x0
 5be:	170080e7          	jalr	368(ra) # 72a <open>
  if(fd < 0)
 5c2:	02054563          	bltz	a0,5ec <stat+0x42>
 5c6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5c8:	85ca                	mv	a1,s2
 5ca:	00000097          	auipc	ra,0x0
 5ce:	178080e7          	jalr	376(ra) # 742 <fstat>
 5d2:	892a                	mv	s2,a0
  close(fd);
 5d4:	8526                	mv	a0,s1
 5d6:	00000097          	auipc	ra,0x0
 5da:	13c080e7          	jalr	316(ra) # 712 <close>
  return r;
}
 5de:	854a                	mv	a0,s2
 5e0:	60e2                	ld	ra,24(sp)
 5e2:	6442                	ld	s0,16(sp)
 5e4:	64a2                	ld	s1,8(sp)
 5e6:	6902                	ld	s2,0(sp)
 5e8:	6105                	add	sp,sp,32
 5ea:	8082                	ret
    return -1;
 5ec:	597d                	li	s2,-1
 5ee:	bfc5                	j	5de <stat+0x34>

00000000000005f0 <atoi>:

int
atoi(const char *s)
{
 5f0:	1141                	add	sp,sp,-16
 5f2:	e422                	sd	s0,8(sp)
 5f4:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5f6:	00054683          	lbu	a3,0(a0)
 5fa:	fd06879b          	addw	a5,a3,-48
 5fe:	0ff7f793          	zext.b	a5,a5
 602:	4625                	li	a2,9
 604:	02f66863          	bltu	a2,a5,634 <atoi+0x44>
 608:	872a                	mv	a4,a0
  n = 0;
 60a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 60c:	0705                	add	a4,a4,1
 60e:	0025179b          	sllw	a5,a0,0x2
 612:	9fa9                	addw	a5,a5,a0
 614:	0017979b          	sllw	a5,a5,0x1
 618:	9fb5                	addw	a5,a5,a3
 61a:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 61e:	00074683          	lbu	a3,0(a4)
 622:	fd06879b          	addw	a5,a3,-48
 626:	0ff7f793          	zext.b	a5,a5
 62a:	fef671e3          	bgeu	a2,a5,60c <atoi+0x1c>
  return n;
}
 62e:	6422                	ld	s0,8(sp)
 630:	0141                	add	sp,sp,16
 632:	8082                	ret
  n = 0;
 634:	4501                	li	a0,0
 636:	bfe5                	j	62e <atoi+0x3e>

0000000000000638 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 638:	1141                	add	sp,sp,-16
 63a:	e422                	sd	s0,8(sp)
 63c:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 63e:	02b57463          	bgeu	a0,a1,666 <memmove+0x2e>
    while(n-- > 0)
 642:	00c05f63          	blez	a2,660 <memmove+0x28>
 646:	1602                	sll	a2,a2,0x20
 648:	9201                	srl	a2,a2,0x20
 64a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 64e:	872a                	mv	a4,a0
      *dst++ = *src++;
 650:	0585                	add	a1,a1,1
 652:	0705                	add	a4,a4,1
 654:	fff5c683          	lbu	a3,-1(a1)
 658:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 65c:	fee79ae3          	bne	a5,a4,650 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 660:	6422                	ld	s0,8(sp)
 662:	0141                	add	sp,sp,16
 664:	8082                	ret
    dst += n;
 666:	00c50733          	add	a4,a0,a2
    src += n;
 66a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 66c:	fec05ae3          	blez	a2,660 <memmove+0x28>
 670:	fff6079b          	addw	a5,a2,-1
 674:	1782                	sll	a5,a5,0x20
 676:	9381                	srl	a5,a5,0x20
 678:	fff7c793          	not	a5,a5
 67c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 67e:	15fd                	add	a1,a1,-1
 680:	177d                	add	a4,a4,-1
 682:	0005c683          	lbu	a3,0(a1)
 686:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 68a:	fee79ae3          	bne	a5,a4,67e <memmove+0x46>
 68e:	bfc9                	j	660 <memmove+0x28>

0000000000000690 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 690:	1141                	add	sp,sp,-16
 692:	e422                	sd	s0,8(sp)
 694:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 696:	ca05                	beqz	a2,6c6 <memcmp+0x36>
 698:	fff6069b          	addw	a3,a2,-1
 69c:	1682                	sll	a3,a3,0x20
 69e:	9281                	srl	a3,a3,0x20
 6a0:	0685                	add	a3,a3,1
 6a2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 6a4:	00054783          	lbu	a5,0(a0)
 6a8:	0005c703          	lbu	a4,0(a1)
 6ac:	00e79863          	bne	a5,a4,6bc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 6b0:	0505                	add	a0,a0,1
    p2++;
 6b2:	0585                	add	a1,a1,1
  while (n-- > 0) {
 6b4:	fed518e3          	bne	a0,a3,6a4 <memcmp+0x14>
  }
  return 0;
 6b8:	4501                	li	a0,0
 6ba:	a019                	j	6c0 <memcmp+0x30>
      return *p1 - *p2;
 6bc:	40e7853b          	subw	a0,a5,a4
}
 6c0:	6422                	ld	s0,8(sp)
 6c2:	0141                	add	sp,sp,16
 6c4:	8082                	ret
  return 0;
 6c6:	4501                	li	a0,0
 6c8:	bfe5                	j	6c0 <memcmp+0x30>

00000000000006ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6ca:	1141                	add	sp,sp,-16
 6cc:	e406                	sd	ra,8(sp)
 6ce:	e022                	sd	s0,0(sp)
 6d0:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 6d2:	00000097          	auipc	ra,0x0
 6d6:	f66080e7          	jalr	-154(ra) # 638 <memmove>
}
 6da:	60a2                	ld	ra,8(sp)
 6dc:	6402                	ld	s0,0(sp)
 6de:	0141                	add	sp,sp,16
 6e0:	8082                	ret

00000000000006e2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 6e2:	4885                	li	a7,1
 ecall
 6e4:	00000073          	ecall
 ret
 6e8:	8082                	ret

00000000000006ea <exit>:
.global exit
exit:
 li a7, SYS_exit
 6ea:	4889                	li	a7,2
 ecall
 6ec:	00000073          	ecall
 ret
 6f0:	8082                	ret

00000000000006f2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 6f2:	488d                	li	a7,3
 ecall
 6f4:	00000073          	ecall
 ret
 6f8:	8082                	ret

00000000000006fa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 6fa:	4891                	li	a7,4
 ecall
 6fc:	00000073          	ecall
 ret
 700:	8082                	ret

0000000000000702 <read>:
.global read
read:
 li a7, SYS_read
 702:	4895                	li	a7,5
 ecall
 704:	00000073          	ecall
 ret
 708:	8082                	ret

000000000000070a <write>:
.global write
write:
 li a7, SYS_write
 70a:	48c1                	li	a7,16
 ecall
 70c:	00000073          	ecall
 ret
 710:	8082                	ret

0000000000000712 <close>:
.global close
close:
 li a7, SYS_close
 712:	48d5                	li	a7,21
 ecall
 714:	00000073          	ecall
 ret
 718:	8082                	ret

000000000000071a <kill>:
.global kill
kill:
 li a7, SYS_kill
 71a:	4899                	li	a7,6
 ecall
 71c:	00000073          	ecall
 ret
 720:	8082                	ret

0000000000000722 <exec>:
.global exec
exec:
 li a7, SYS_exec
 722:	489d                	li	a7,7
 ecall
 724:	00000073          	ecall
 ret
 728:	8082                	ret

000000000000072a <open>:
.global open
open:
 li a7, SYS_open
 72a:	48bd                	li	a7,15
 ecall
 72c:	00000073          	ecall
 ret
 730:	8082                	ret

0000000000000732 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 732:	48c5                	li	a7,17
 ecall
 734:	00000073          	ecall
 ret
 738:	8082                	ret

000000000000073a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 73a:	48c9                	li	a7,18
 ecall
 73c:	00000073          	ecall
 ret
 740:	8082                	ret

0000000000000742 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 742:	48a1                	li	a7,8
 ecall
 744:	00000073          	ecall
 ret
 748:	8082                	ret

000000000000074a <link>:
.global link
link:
 li a7, SYS_link
 74a:	48cd                	li	a7,19
 ecall
 74c:	00000073          	ecall
 ret
 750:	8082                	ret

0000000000000752 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 752:	48d1                	li	a7,20
 ecall
 754:	00000073          	ecall
 ret
 758:	8082                	ret

000000000000075a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 75a:	48a5                	li	a7,9
 ecall
 75c:	00000073          	ecall
 ret
 760:	8082                	ret

0000000000000762 <dup>:
.global dup
dup:
 li a7, SYS_dup
 762:	48a9                	li	a7,10
 ecall
 764:	00000073          	ecall
 ret
 768:	8082                	ret

000000000000076a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 76a:	48ad                	li	a7,11
 ecall
 76c:	00000073          	ecall
 ret
 770:	8082                	ret

0000000000000772 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 772:	48b1                	li	a7,12
 ecall
 774:	00000073          	ecall
 ret
 778:	8082                	ret

000000000000077a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 77a:	48b5                	li	a7,13
 ecall
 77c:	00000073          	ecall
 ret
 780:	8082                	ret

0000000000000782 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 782:	48b9                	li	a7,14
 ecall
 784:	00000073          	ecall
 ret
 788:	8082                	ret

000000000000078a <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 78a:	48d9                	li	a7,22
 ecall
 78c:	00000073          	ecall
 ret
 790:	8082                	ret

0000000000000792 <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
 792:	48dd                	li	a7,23
 ecall
 794:	00000073          	ecall
 ret
 798:	8082                	ret

000000000000079a <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 79a:	48e1                	li	a7,24
 ecall
 79c:	00000073          	ecall
 ret
 7a0:	8082                	ret

00000000000007a2 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 7a2:	48e5                	li	a7,25
 ecall
 7a4:	00000073          	ecall
 ret
 7a8:	8082                	ret

00000000000007aa <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7aa:	1101                	add	sp,sp,-32
 7ac:	ec06                	sd	ra,24(sp)
 7ae:	e822                	sd	s0,16(sp)
 7b0:	1000                	add	s0,sp,32
 7b2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7b6:	4605                	li	a2,1
 7b8:	fef40593          	add	a1,s0,-17
 7bc:	00000097          	auipc	ra,0x0
 7c0:	f4e080e7          	jalr	-178(ra) # 70a <write>
}
 7c4:	60e2                	ld	ra,24(sp)
 7c6:	6442                	ld	s0,16(sp)
 7c8:	6105                	add	sp,sp,32
 7ca:	8082                	ret

00000000000007cc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7cc:	7139                	add	sp,sp,-64
 7ce:	fc06                	sd	ra,56(sp)
 7d0:	f822                	sd	s0,48(sp)
 7d2:	f426                	sd	s1,40(sp)
 7d4:	f04a                	sd	s2,32(sp)
 7d6:	ec4e                	sd	s3,24(sp)
 7d8:	0080                	add	s0,sp,64
 7da:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 7dc:	c299                	beqz	a3,7e2 <printint+0x16>
 7de:	0805c963          	bltz	a1,870 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 7e2:	2581                	sext.w	a1,a1
  neg = 0;
 7e4:	4881                	li	a7,0
 7e6:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 7ea:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 7ec:	2601                	sext.w	a2,a2
 7ee:	00000517          	auipc	a0,0x0
 7f2:	66250513          	add	a0,a0,1634 # e50 <digits>
 7f6:	883a                	mv	a6,a4
 7f8:	2705                	addw	a4,a4,1
 7fa:	02c5f7bb          	remuw	a5,a1,a2
 7fe:	1782                	sll	a5,a5,0x20
 800:	9381                	srl	a5,a5,0x20
 802:	97aa                	add	a5,a5,a0
 804:	0007c783          	lbu	a5,0(a5)
 808:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 80c:	0005879b          	sext.w	a5,a1
 810:	02c5d5bb          	divuw	a1,a1,a2
 814:	0685                	add	a3,a3,1
 816:	fec7f0e3          	bgeu	a5,a2,7f6 <printint+0x2a>
  if(neg)
 81a:	00088c63          	beqz	a7,832 <printint+0x66>
    buf[i++] = '-';
 81e:	fd070793          	add	a5,a4,-48
 822:	00878733          	add	a4,a5,s0
 826:	02d00793          	li	a5,45
 82a:	fef70823          	sb	a5,-16(a4)
 82e:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 832:	02e05863          	blez	a4,862 <printint+0x96>
 836:	fc040793          	add	a5,s0,-64
 83a:	00e78933          	add	s2,a5,a4
 83e:	fff78993          	add	s3,a5,-1
 842:	99ba                	add	s3,s3,a4
 844:	377d                	addw	a4,a4,-1
 846:	1702                	sll	a4,a4,0x20
 848:	9301                	srl	a4,a4,0x20
 84a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 84e:	fff94583          	lbu	a1,-1(s2)
 852:	8526                	mv	a0,s1
 854:	00000097          	auipc	ra,0x0
 858:	f56080e7          	jalr	-170(ra) # 7aa <putc>
  while(--i >= 0)
 85c:	197d                	add	s2,s2,-1
 85e:	ff3918e3          	bne	s2,s3,84e <printint+0x82>
}
 862:	70e2                	ld	ra,56(sp)
 864:	7442                	ld	s0,48(sp)
 866:	74a2                	ld	s1,40(sp)
 868:	7902                	ld	s2,32(sp)
 86a:	69e2                	ld	s3,24(sp)
 86c:	6121                	add	sp,sp,64
 86e:	8082                	ret
    x = -xx;
 870:	40b005bb          	negw	a1,a1
    neg = 1;
 874:	4885                	li	a7,1
    x = -xx;
 876:	bf85                	j	7e6 <printint+0x1a>

0000000000000878 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 878:	715d                	add	sp,sp,-80
 87a:	e486                	sd	ra,72(sp)
 87c:	e0a2                	sd	s0,64(sp)
 87e:	fc26                	sd	s1,56(sp)
 880:	f84a                	sd	s2,48(sp)
 882:	f44e                	sd	s3,40(sp)
 884:	f052                	sd	s4,32(sp)
 886:	ec56                	sd	s5,24(sp)
 888:	e85a                	sd	s6,16(sp)
 88a:	e45e                	sd	s7,8(sp)
 88c:	e062                	sd	s8,0(sp)
 88e:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 890:	0005c903          	lbu	s2,0(a1)
 894:	18090c63          	beqz	s2,a2c <vprintf+0x1b4>
 898:	8aaa                	mv	s5,a0
 89a:	8bb2                	mv	s7,a2
 89c:	00158493          	add	s1,a1,1
  state = 0;
 8a0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 8a2:	02500a13          	li	s4,37
 8a6:	4b55                	li	s6,21
 8a8:	a839                	j	8c6 <vprintf+0x4e>
        putc(fd, c);
 8aa:	85ca                	mv	a1,s2
 8ac:	8556                	mv	a0,s5
 8ae:	00000097          	auipc	ra,0x0
 8b2:	efc080e7          	jalr	-260(ra) # 7aa <putc>
 8b6:	a019                	j	8bc <vprintf+0x44>
    } else if(state == '%'){
 8b8:	01498d63          	beq	s3,s4,8d2 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 8bc:	0485                	add	s1,s1,1
 8be:	fff4c903          	lbu	s2,-1(s1)
 8c2:	16090563          	beqz	s2,a2c <vprintf+0x1b4>
    if(state == 0){
 8c6:	fe0999e3          	bnez	s3,8b8 <vprintf+0x40>
      if(c == '%'){
 8ca:	ff4910e3          	bne	s2,s4,8aa <vprintf+0x32>
        state = '%';
 8ce:	89d2                	mv	s3,s4
 8d0:	b7f5                	j	8bc <vprintf+0x44>
      if(c == 'd'){
 8d2:	13490263          	beq	s2,s4,9f6 <vprintf+0x17e>
 8d6:	f9d9079b          	addw	a5,s2,-99
 8da:	0ff7f793          	zext.b	a5,a5
 8de:	12fb6563          	bltu	s6,a5,a08 <vprintf+0x190>
 8e2:	f9d9079b          	addw	a5,s2,-99
 8e6:	0ff7f713          	zext.b	a4,a5
 8ea:	10eb6f63          	bltu	s6,a4,a08 <vprintf+0x190>
 8ee:	00271793          	sll	a5,a4,0x2
 8f2:	00000717          	auipc	a4,0x0
 8f6:	50670713          	add	a4,a4,1286 # df8 <malloc+0x2ce>
 8fa:	97ba                	add	a5,a5,a4
 8fc:	439c                	lw	a5,0(a5)
 8fe:	97ba                	add	a5,a5,a4
 900:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 902:	008b8913          	add	s2,s7,8
 906:	4685                	li	a3,1
 908:	4629                	li	a2,10
 90a:	000ba583          	lw	a1,0(s7)
 90e:	8556                	mv	a0,s5
 910:	00000097          	auipc	ra,0x0
 914:	ebc080e7          	jalr	-324(ra) # 7cc <printint>
 918:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 91a:	4981                	li	s3,0
 91c:	b745                	j	8bc <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 91e:	008b8913          	add	s2,s7,8
 922:	4681                	li	a3,0
 924:	4629                	li	a2,10
 926:	000ba583          	lw	a1,0(s7)
 92a:	8556                	mv	a0,s5
 92c:	00000097          	auipc	ra,0x0
 930:	ea0080e7          	jalr	-352(ra) # 7cc <printint>
 934:	8bca                	mv	s7,s2
      state = 0;
 936:	4981                	li	s3,0
 938:	b751                	j	8bc <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 93a:	008b8913          	add	s2,s7,8
 93e:	4681                	li	a3,0
 940:	4641                	li	a2,16
 942:	000ba583          	lw	a1,0(s7)
 946:	8556                	mv	a0,s5
 948:	00000097          	auipc	ra,0x0
 94c:	e84080e7          	jalr	-380(ra) # 7cc <printint>
 950:	8bca                	mv	s7,s2
      state = 0;
 952:	4981                	li	s3,0
 954:	b7a5                	j	8bc <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 956:	008b8c13          	add	s8,s7,8
 95a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 95e:	03000593          	li	a1,48
 962:	8556                	mv	a0,s5
 964:	00000097          	auipc	ra,0x0
 968:	e46080e7          	jalr	-442(ra) # 7aa <putc>
  putc(fd, 'x');
 96c:	07800593          	li	a1,120
 970:	8556                	mv	a0,s5
 972:	00000097          	auipc	ra,0x0
 976:	e38080e7          	jalr	-456(ra) # 7aa <putc>
 97a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 97c:	00000b97          	auipc	s7,0x0
 980:	4d4b8b93          	add	s7,s7,1236 # e50 <digits>
 984:	03c9d793          	srl	a5,s3,0x3c
 988:	97de                	add	a5,a5,s7
 98a:	0007c583          	lbu	a1,0(a5)
 98e:	8556                	mv	a0,s5
 990:	00000097          	auipc	ra,0x0
 994:	e1a080e7          	jalr	-486(ra) # 7aa <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 998:	0992                	sll	s3,s3,0x4
 99a:	397d                	addw	s2,s2,-1
 99c:	fe0914e3          	bnez	s2,984 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 9a0:	8be2                	mv	s7,s8
      state = 0;
 9a2:	4981                	li	s3,0
 9a4:	bf21                	j	8bc <vprintf+0x44>
        s = va_arg(ap, char*);
 9a6:	008b8993          	add	s3,s7,8
 9aa:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 9ae:	02090163          	beqz	s2,9d0 <vprintf+0x158>
        while(*s != 0){
 9b2:	00094583          	lbu	a1,0(s2)
 9b6:	c9a5                	beqz	a1,a26 <vprintf+0x1ae>
          putc(fd, *s);
 9b8:	8556                	mv	a0,s5
 9ba:	00000097          	auipc	ra,0x0
 9be:	df0080e7          	jalr	-528(ra) # 7aa <putc>
          s++;
 9c2:	0905                	add	s2,s2,1
        while(*s != 0){
 9c4:	00094583          	lbu	a1,0(s2)
 9c8:	f9e5                	bnez	a1,9b8 <vprintf+0x140>
        s = va_arg(ap, char*);
 9ca:	8bce                	mv	s7,s3
      state = 0;
 9cc:	4981                	li	s3,0
 9ce:	b5fd                	j	8bc <vprintf+0x44>
          s = "(null)";
 9d0:	00000917          	auipc	s2,0x0
 9d4:	42090913          	add	s2,s2,1056 # df0 <malloc+0x2c6>
        while(*s != 0){
 9d8:	02800593          	li	a1,40
 9dc:	bff1                	j	9b8 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 9de:	008b8913          	add	s2,s7,8
 9e2:	000bc583          	lbu	a1,0(s7)
 9e6:	8556                	mv	a0,s5
 9e8:	00000097          	auipc	ra,0x0
 9ec:	dc2080e7          	jalr	-574(ra) # 7aa <putc>
 9f0:	8bca                	mv	s7,s2
      state = 0;
 9f2:	4981                	li	s3,0
 9f4:	b5e1                	j	8bc <vprintf+0x44>
        putc(fd, c);
 9f6:	02500593          	li	a1,37
 9fa:	8556                	mv	a0,s5
 9fc:	00000097          	auipc	ra,0x0
 a00:	dae080e7          	jalr	-594(ra) # 7aa <putc>
      state = 0;
 a04:	4981                	li	s3,0
 a06:	bd5d                	j	8bc <vprintf+0x44>
        putc(fd, '%');
 a08:	02500593          	li	a1,37
 a0c:	8556                	mv	a0,s5
 a0e:	00000097          	auipc	ra,0x0
 a12:	d9c080e7          	jalr	-612(ra) # 7aa <putc>
        putc(fd, c);
 a16:	85ca                	mv	a1,s2
 a18:	8556                	mv	a0,s5
 a1a:	00000097          	auipc	ra,0x0
 a1e:	d90080e7          	jalr	-624(ra) # 7aa <putc>
      state = 0;
 a22:	4981                	li	s3,0
 a24:	bd61                	j	8bc <vprintf+0x44>
        s = va_arg(ap, char*);
 a26:	8bce                	mv	s7,s3
      state = 0;
 a28:	4981                	li	s3,0
 a2a:	bd49                	j	8bc <vprintf+0x44>
    }
  }
}
 a2c:	60a6                	ld	ra,72(sp)
 a2e:	6406                	ld	s0,64(sp)
 a30:	74e2                	ld	s1,56(sp)
 a32:	7942                	ld	s2,48(sp)
 a34:	79a2                	ld	s3,40(sp)
 a36:	7a02                	ld	s4,32(sp)
 a38:	6ae2                	ld	s5,24(sp)
 a3a:	6b42                	ld	s6,16(sp)
 a3c:	6ba2                	ld	s7,8(sp)
 a3e:	6c02                	ld	s8,0(sp)
 a40:	6161                	add	sp,sp,80
 a42:	8082                	ret

0000000000000a44 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a44:	715d                	add	sp,sp,-80
 a46:	ec06                	sd	ra,24(sp)
 a48:	e822                	sd	s0,16(sp)
 a4a:	1000                	add	s0,sp,32
 a4c:	e010                	sd	a2,0(s0)
 a4e:	e414                	sd	a3,8(s0)
 a50:	e818                	sd	a4,16(s0)
 a52:	ec1c                	sd	a5,24(s0)
 a54:	03043023          	sd	a6,32(s0)
 a58:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a5c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a60:	8622                	mv	a2,s0
 a62:	00000097          	auipc	ra,0x0
 a66:	e16080e7          	jalr	-490(ra) # 878 <vprintf>
}
 a6a:	60e2                	ld	ra,24(sp)
 a6c:	6442                	ld	s0,16(sp)
 a6e:	6161                	add	sp,sp,80
 a70:	8082                	ret

0000000000000a72 <printf>:

void
printf(const char *fmt, ...)
{
 a72:	711d                	add	sp,sp,-96
 a74:	ec06                	sd	ra,24(sp)
 a76:	e822                	sd	s0,16(sp)
 a78:	1000                	add	s0,sp,32
 a7a:	e40c                	sd	a1,8(s0)
 a7c:	e810                	sd	a2,16(s0)
 a7e:	ec14                	sd	a3,24(s0)
 a80:	f018                	sd	a4,32(s0)
 a82:	f41c                	sd	a5,40(s0)
 a84:	03043823          	sd	a6,48(s0)
 a88:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a8c:	00840613          	add	a2,s0,8
 a90:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a94:	85aa                	mv	a1,a0
 a96:	4505                	li	a0,1
 a98:	00000097          	auipc	ra,0x0
 a9c:	de0080e7          	jalr	-544(ra) # 878 <vprintf>
}
 aa0:	60e2                	ld	ra,24(sp)
 aa2:	6442                	ld	s0,16(sp)
 aa4:	6125                	add	sp,sp,96
 aa6:	8082                	ret

0000000000000aa8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 aa8:	1141                	add	sp,sp,-16
 aaa:	e422                	sd	s0,8(sp)
 aac:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 aae:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ab2:	00000797          	auipc	a5,0x0
 ab6:	5567b783          	ld	a5,1366(a5) # 1008 <freep>
 aba:	a02d                	j	ae4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 abc:	4618                	lw	a4,8(a2)
 abe:	9f2d                	addw	a4,a4,a1
 ac0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ac4:	6398                	ld	a4,0(a5)
 ac6:	6310                	ld	a2,0(a4)
 ac8:	a83d                	j	b06 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 aca:	ff852703          	lw	a4,-8(a0)
 ace:	9f31                	addw	a4,a4,a2
 ad0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 ad2:	ff053683          	ld	a3,-16(a0)
 ad6:	a091                	j	b1a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ad8:	6398                	ld	a4,0(a5)
 ada:	00e7e463          	bltu	a5,a4,ae2 <free+0x3a>
 ade:	00e6ea63          	bltu	a3,a4,af2 <free+0x4a>
{
 ae2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 ae4:	fed7fae3          	bgeu	a5,a3,ad8 <free+0x30>
 ae8:	6398                	ld	a4,0(a5)
 aea:	00e6e463          	bltu	a3,a4,af2 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 aee:	fee7eae3          	bltu	a5,a4,ae2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 af2:	ff852583          	lw	a1,-8(a0)
 af6:	6390                	ld	a2,0(a5)
 af8:	02059813          	sll	a6,a1,0x20
 afc:	01c85713          	srl	a4,a6,0x1c
 b00:	9736                	add	a4,a4,a3
 b02:	fae60de3          	beq	a2,a4,abc <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 b06:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b0a:	4790                	lw	a2,8(a5)
 b0c:	02061593          	sll	a1,a2,0x20
 b10:	01c5d713          	srl	a4,a1,0x1c
 b14:	973e                	add	a4,a4,a5
 b16:	fae68ae3          	beq	a3,a4,aca <free+0x22>
    p->s.ptr = bp->s.ptr;
 b1a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 b1c:	00000717          	auipc	a4,0x0
 b20:	4ef73623          	sd	a5,1260(a4) # 1008 <freep>
}
 b24:	6422                	ld	s0,8(sp)
 b26:	0141                	add	sp,sp,16
 b28:	8082                	ret

0000000000000b2a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b2a:	7139                	add	sp,sp,-64
 b2c:	fc06                	sd	ra,56(sp)
 b2e:	f822                	sd	s0,48(sp)
 b30:	f426                	sd	s1,40(sp)
 b32:	f04a                	sd	s2,32(sp)
 b34:	ec4e                	sd	s3,24(sp)
 b36:	e852                	sd	s4,16(sp)
 b38:	e456                	sd	s5,8(sp)
 b3a:	e05a                	sd	s6,0(sp)
 b3c:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b3e:	02051493          	sll	s1,a0,0x20
 b42:	9081                	srl	s1,s1,0x20
 b44:	04bd                	add	s1,s1,15
 b46:	8091                	srl	s1,s1,0x4
 b48:	0014899b          	addw	s3,s1,1
 b4c:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 b4e:	00000517          	auipc	a0,0x0
 b52:	4ba53503          	ld	a0,1210(a0) # 1008 <freep>
 b56:	c515                	beqz	a0,b82 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b58:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b5a:	4798                	lw	a4,8(a5)
 b5c:	02977f63          	bgeu	a4,s1,b9a <malloc+0x70>
  if(nu < 4096)
 b60:	8a4e                	mv	s4,s3
 b62:	0009871b          	sext.w	a4,s3
 b66:	6685                	lui	a3,0x1
 b68:	00d77363          	bgeu	a4,a3,b6e <malloc+0x44>
 b6c:	6a05                	lui	s4,0x1
 b6e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b72:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b76:	00000917          	auipc	s2,0x0
 b7a:	49290913          	add	s2,s2,1170 # 1008 <freep>
  if(p == (char*)-1)
 b7e:	5afd                	li	s5,-1
 b80:	a895                	j	bf4 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 b82:	00000797          	auipc	a5,0x0
 b86:	48e78793          	add	a5,a5,1166 # 1010 <base>
 b8a:	00000717          	auipc	a4,0x0
 b8e:	46f73f23          	sd	a5,1150(a4) # 1008 <freep>
 b92:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b94:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b98:	b7e1                	j	b60 <malloc+0x36>
      if(p->s.size == nunits)
 b9a:	02e48c63          	beq	s1,a4,bd2 <malloc+0xa8>
        p->s.size -= nunits;
 b9e:	4137073b          	subw	a4,a4,s3
 ba2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ba4:	02071693          	sll	a3,a4,0x20
 ba8:	01c6d713          	srl	a4,a3,0x1c
 bac:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 bae:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 bb2:	00000717          	auipc	a4,0x0
 bb6:	44a73b23          	sd	a0,1110(a4) # 1008 <freep>
      return (void*)(p + 1);
 bba:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 bbe:	70e2                	ld	ra,56(sp)
 bc0:	7442                	ld	s0,48(sp)
 bc2:	74a2                	ld	s1,40(sp)
 bc4:	7902                	ld	s2,32(sp)
 bc6:	69e2                	ld	s3,24(sp)
 bc8:	6a42                	ld	s4,16(sp)
 bca:	6aa2                	ld	s5,8(sp)
 bcc:	6b02                	ld	s6,0(sp)
 bce:	6121                	add	sp,sp,64
 bd0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 bd2:	6398                	ld	a4,0(a5)
 bd4:	e118                	sd	a4,0(a0)
 bd6:	bff1                	j	bb2 <malloc+0x88>
  hp->s.size = nu;
 bd8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 bdc:	0541                	add	a0,a0,16
 bde:	00000097          	auipc	ra,0x0
 be2:	eca080e7          	jalr	-310(ra) # aa8 <free>
  return freep;
 be6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 bea:	d971                	beqz	a0,bbe <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bec:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bee:	4798                	lw	a4,8(a5)
 bf0:	fa9775e3          	bgeu	a4,s1,b9a <malloc+0x70>
    if(p == freep)
 bf4:	00093703          	ld	a4,0(s2)
 bf8:	853e                	mv	a0,a5
 bfa:	fef719e3          	bne	a4,a5,bec <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 bfe:	8552                	mv	a0,s4
 c00:	00000097          	auipc	ra,0x0
 c04:	b72080e7          	jalr	-1166(ra) # 772 <sbrk>
  if(p == (char*)-1)
 c08:	fd5518e3          	bne	a0,s5,bd8 <malloc+0xae>
        return 0;
 c0c:	4501                	li	a0,0
 c0e:	bf45                	j	bbe <malloc+0x94>
