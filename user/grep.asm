
user/_grep:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <matchstar>:
  return 0;
}

// matchstar: search for c*re at beginning of text
int matchstar(int c, char *re, char *text)
{
   0:	7179                	add	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	add	s0,sp,48
  10:	892a                	mv	s2,a0
  12:	89ae                	mv	s3,a1
  14:	84b2                	mv	s1,a2
  do{  // a * matches zero or more instances
    if(matchhere(re, text))
      return 1;
  }while(*text!='\0' && (*text++==c || c=='.'));
  16:	02e00a13          	li	s4,46
    if(matchhere(re, text))
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00000097          	auipc	ra,0x0
  22:	030080e7          	jalr	48(ra) # 4e <matchhere>
  26:	e919                	bnez	a0,3c <matchstar+0x3c>
  }while(*text!='\0' && (*text++==c || c=='.'));
  28:	0004c783          	lbu	a5,0(s1)
  2c:	cb89                	beqz	a5,3e <matchstar+0x3e>
  2e:	0485                	add	s1,s1,1
  30:	2781                	sext.w	a5,a5
  32:	ff2784e3          	beq	a5,s2,1a <matchstar+0x1a>
  36:	ff4902e3          	beq	s2,s4,1a <matchstar+0x1a>
  3a:	a011                	j	3e <matchstar+0x3e>
      return 1;
  3c:	4505                	li	a0,1
  return 0;
}
  3e:	70a2                	ld	ra,40(sp)
  40:	7402                	ld	s0,32(sp)
  42:	64e2                	ld	s1,24(sp)
  44:	6942                	ld	s2,16(sp)
  46:	69a2                	ld	s3,8(sp)
  48:	6a02                	ld	s4,0(sp)
  4a:	6145                	add	sp,sp,48
  4c:	8082                	ret

000000000000004e <matchhere>:
  if(re[0] == '\0')
  4e:	00054703          	lbu	a4,0(a0)
  52:	cb3d                	beqz	a4,c8 <matchhere+0x7a>
{
  54:	1141                	add	sp,sp,-16
  56:	e406                	sd	ra,8(sp)
  58:	e022                	sd	s0,0(sp)
  5a:	0800                	add	s0,sp,16
  5c:	87aa                	mv	a5,a0
  if(re[1] == '*')
  5e:	00154683          	lbu	a3,1(a0)
  62:	02a00613          	li	a2,42
  66:	02c68563          	beq	a3,a2,90 <matchhere+0x42>
  if(re[0] == '$' && re[1] == '\0')
  6a:	02400613          	li	a2,36
  6e:	02c70a63          	beq	a4,a2,a2 <matchhere+0x54>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  72:	0005c683          	lbu	a3,0(a1)
  return 0;
  76:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  78:	ca81                	beqz	a3,88 <matchhere+0x3a>
  7a:	02e00613          	li	a2,46
  7e:	02c70d63          	beq	a4,a2,b8 <matchhere+0x6a>
  return 0;
  82:	4501                	li	a0,0
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  84:	02d70a63          	beq	a4,a3,b8 <matchhere+0x6a>
}
  88:	60a2                	ld	ra,8(sp)
  8a:	6402                	ld	s0,0(sp)
  8c:	0141                	add	sp,sp,16
  8e:	8082                	ret
    return matchstar(re[0], re+2, text);
  90:	862e                	mv	a2,a1
  92:	00250593          	add	a1,a0,2
  96:	853a                	mv	a0,a4
  98:	00000097          	auipc	ra,0x0
  9c:	f68080e7          	jalr	-152(ra) # 0 <matchstar>
  a0:	b7e5                	j	88 <matchhere+0x3a>
  if(re[0] == '$' && re[1] == '\0')
  a2:	c691                	beqz	a3,ae <matchhere+0x60>
  if(*text!='\0' && (re[0]=='.' || re[0]==*text))
  a4:	0005c683          	lbu	a3,0(a1)
  a8:	fee9                	bnez	a3,82 <matchhere+0x34>
  return 0;
  aa:	4501                	li	a0,0
  ac:	bff1                	j	88 <matchhere+0x3a>
    return *text == '\0';
  ae:	0005c503          	lbu	a0,0(a1)
  b2:	00153513          	seqz	a0,a0
  b6:	bfc9                	j	88 <matchhere+0x3a>
    return matchhere(re+1, text+1);
  b8:	0585                	add	a1,a1,1
  ba:	00178513          	add	a0,a5,1
  be:	00000097          	auipc	ra,0x0
  c2:	f90080e7          	jalr	-112(ra) # 4e <matchhere>
  c6:	b7c9                	j	88 <matchhere+0x3a>
    return 1;
  c8:	4505                	li	a0,1
}
  ca:	8082                	ret

00000000000000cc <match>:
{
  cc:	1101                	add	sp,sp,-32
  ce:	ec06                	sd	ra,24(sp)
  d0:	e822                	sd	s0,16(sp)
  d2:	e426                	sd	s1,8(sp)
  d4:	e04a                	sd	s2,0(sp)
  d6:	1000                	add	s0,sp,32
  d8:	892a                	mv	s2,a0
  da:	84ae                	mv	s1,a1
  if(re[0] == '^')
  dc:	00054703          	lbu	a4,0(a0)
  e0:	05e00793          	li	a5,94
  e4:	00f70e63          	beq	a4,a5,100 <match+0x34>
    if(matchhere(re, text))
  e8:	85a6                	mv	a1,s1
  ea:	854a                	mv	a0,s2
  ec:	00000097          	auipc	ra,0x0
  f0:	f62080e7          	jalr	-158(ra) # 4e <matchhere>
  f4:	ed01                	bnez	a0,10c <match+0x40>
  }while(*text++ != '\0');
  f6:	0485                	add	s1,s1,1
  f8:	fff4c783          	lbu	a5,-1(s1)
  fc:	f7f5                	bnez	a5,e8 <match+0x1c>
  fe:	a801                	j	10e <match+0x42>
    return matchhere(re+1, text);
 100:	0505                	add	a0,a0,1
 102:	00000097          	auipc	ra,0x0
 106:	f4c080e7          	jalr	-180(ra) # 4e <matchhere>
 10a:	a011                	j	10e <match+0x42>
      return 1;
 10c:	4505                	li	a0,1
}
 10e:	60e2                	ld	ra,24(sp)
 110:	6442                	ld	s0,16(sp)
 112:	64a2                	ld	s1,8(sp)
 114:	6902                	ld	s2,0(sp)
 116:	6105                	add	sp,sp,32
 118:	8082                	ret

000000000000011a <grep>:
{
 11a:	715d                	add	sp,sp,-80
 11c:	e486                	sd	ra,72(sp)
 11e:	e0a2                	sd	s0,64(sp)
 120:	fc26                	sd	s1,56(sp)
 122:	f84a                	sd	s2,48(sp)
 124:	f44e                	sd	s3,40(sp)
 126:	f052                	sd	s4,32(sp)
 128:	ec56                	sd	s5,24(sp)
 12a:	e85a                	sd	s6,16(sp)
 12c:	e45e                	sd	s7,8(sp)
 12e:	e062                	sd	s8,0(sp)
 130:	0880                	add	s0,sp,80
 132:	89aa                	mv	s3,a0
 134:	8b2e                	mv	s6,a1
  m = 0;
 136:	4a01                	li	s4,0
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 138:	3ff00b93          	li	s7,1023
 13c:	00001a97          	auipc	s5,0x1
 140:	ed4a8a93          	add	s5,s5,-300 # 1010 <buf>
 144:	a0a1                	j	18c <grep+0x72>
      p = q+1;
 146:	00148913          	add	s2,s1,1
    while((q = strchr(p, '\n')) != 0){
 14a:	45a9                	li	a1,10
 14c:	854a                	mv	a0,s2
 14e:	00000097          	auipc	ra,0x0
 152:	20a080e7          	jalr	522(ra) # 358 <strchr>
 156:	84aa                	mv	s1,a0
 158:	c905                	beqz	a0,188 <grep+0x6e>
      *q = 0;
 15a:	00048023          	sb	zero,0(s1)
      if(match(pattern, p)){
 15e:	85ca                	mv	a1,s2
 160:	854e                	mv	a0,s3
 162:	00000097          	auipc	ra,0x0
 166:	f6a080e7          	jalr	-150(ra) # cc <match>
 16a:	dd71                	beqz	a0,146 <grep+0x2c>
        *q = '\n';
 16c:	47a9                	li	a5,10
 16e:	00f48023          	sb	a5,0(s1)
        write(1, p, q+1 - p);
 172:	00148613          	add	a2,s1,1
 176:	4126063b          	subw	a2,a2,s2
 17a:	85ca                	mv	a1,s2
 17c:	4505                	li	a0,1
 17e:	00000097          	auipc	ra,0x0
 182:	3d2080e7          	jalr	978(ra) # 550 <write>
 186:	b7c1                	j	146 <grep+0x2c>
    if(m > 0){
 188:	03404763          	bgtz	s4,1b6 <grep+0x9c>
  while((n = read(fd, buf+m, sizeof(buf)-m-1)) > 0){
 18c:	414b863b          	subw	a2,s7,s4
 190:	014a85b3          	add	a1,s5,s4
 194:	855a                	mv	a0,s6
 196:	00000097          	auipc	ra,0x0
 19a:	3b2080e7          	jalr	946(ra) # 548 <read>
 19e:	02a05b63          	blez	a0,1d4 <grep+0xba>
    m += n;
 1a2:	00aa0c3b          	addw	s8,s4,a0
 1a6:	000c0a1b          	sext.w	s4,s8
    buf[m] = '\0';
 1aa:	014a87b3          	add	a5,s5,s4
 1ae:	00078023          	sb	zero,0(a5)
    p = buf;
 1b2:	8956                	mv	s2,s5
    while((q = strchr(p, '\n')) != 0){
 1b4:	bf59                	j	14a <grep+0x30>
      m -= p - buf;
 1b6:	00001517          	auipc	a0,0x1
 1ba:	e5a50513          	add	a0,a0,-422 # 1010 <buf>
 1be:	40a90a33          	sub	s4,s2,a0
 1c2:	414c0a3b          	subw	s4,s8,s4
      memmove(buf, p, m);
 1c6:	8652                	mv	a2,s4
 1c8:	85ca                	mv	a1,s2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	2b4080e7          	jalr	692(ra) # 47e <memmove>
 1d2:	bf6d                	j	18c <grep+0x72>
}
 1d4:	60a6                	ld	ra,72(sp)
 1d6:	6406                	ld	s0,64(sp)
 1d8:	74e2                	ld	s1,56(sp)
 1da:	7942                	ld	s2,48(sp)
 1dc:	79a2                	ld	s3,40(sp)
 1de:	7a02                	ld	s4,32(sp)
 1e0:	6ae2                	ld	s5,24(sp)
 1e2:	6b42                	ld	s6,16(sp)
 1e4:	6ba2                	ld	s7,8(sp)
 1e6:	6c02                	ld	s8,0(sp)
 1e8:	6161                	add	sp,sp,80
 1ea:	8082                	ret

00000000000001ec <main>:
{
 1ec:	7179                	add	sp,sp,-48
 1ee:	f406                	sd	ra,40(sp)
 1f0:	f022                	sd	s0,32(sp)
 1f2:	ec26                	sd	s1,24(sp)
 1f4:	e84a                	sd	s2,16(sp)
 1f6:	e44e                	sd	s3,8(sp)
 1f8:	e052                	sd	s4,0(sp)
 1fa:	1800                	add	s0,sp,48
  if(argc <= 1){
 1fc:	4785                	li	a5,1
 1fe:	04a7de63          	bge	a5,a0,25a <main+0x6e>
  pattern = argv[1];
 202:	0085ba03          	ld	s4,8(a1)
  if(argc <= 2){
 206:	4789                	li	a5,2
 208:	06a7d763          	bge	a5,a0,276 <main+0x8a>
 20c:	01058913          	add	s2,a1,16
 210:	ffd5099b          	addw	s3,a0,-3
 214:	02099793          	sll	a5,s3,0x20
 218:	01d7d993          	srl	s3,a5,0x1d
 21c:	05e1                	add	a1,a1,24
 21e:	99ae                	add	s3,s3,a1
    if((fd = open(argv[i], 0)) < 0){
 220:	4581                	li	a1,0
 222:	00093503          	ld	a0,0(s2)
 226:	00000097          	auipc	ra,0x0
 22a:	34a080e7          	jalr	842(ra) # 570 <open>
 22e:	84aa                	mv	s1,a0
 230:	04054e63          	bltz	a0,28c <main+0xa0>
    grep(pattern, fd);
 234:	85aa                	mv	a1,a0
 236:	8552                	mv	a0,s4
 238:	00000097          	auipc	ra,0x0
 23c:	ee2080e7          	jalr	-286(ra) # 11a <grep>
    close(fd);
 240:	8526                	mv	a0,s1
 242:	00000097          	auipc	ra,0x0
 246:	316080e7          	jalr	790(ra) # 558 <close>
  for(i = 2; i < argc; i++){
 24a:	0921                	add	s2,s2,8
 24c:	fd391ae3          	bne	s2,s3,220 <main+0x34>
  exit(0);
 250:	4501                	li	a0,0
 252:	00000097          	auipc	ra,0x0
 256:	2de080e7          	jalr	734(ra) # 530 <exit>
    fprintf(2, "usage: grep pattern [file ...]\n");
 25a:	00001597          	auipc	a1,0x1
 25e:	80658593          	add	a1,a1,-2042 # a60 <malloc+0xf0>
 262:	4509                	li	a0,2
 264:	00000097          	auipc	ra,0x0
 268:	626080e7          	jalr	1574(ra) # 88a <fprintf>
    exit(1);
 26c:	4505                	li	a0,1
 26e:	00000097          	auipc	ra,0x0
 272:	2c2080e7          	jalr	706(ra) # 530 <exit>
    grep(pattern, 0);
 276:	4581                	li	a1,0
 278:	8552                	mv	a0,s4
 27a:	00000097          	auipc	ra,0x0
 27e:	ea0080e7          	jalr	-352(ra) # 11a <grep>
    exit(0);
 282:	4501                	li	a0,0
 284:	00000097          	auipc	ra,0x0
 288:	2ac080e7          	jalr	684(ra) # 530 <exit>
      printf("grep: cannot open %s\n", argv[i]);
 28c:	00093583          	ld	a1,0(s2)
 290:	00000517          	auipc	a0,0x0
 294:	7f050513          	add	a0,a0,2032 # a80 <malloc+0x110>
 298:	00000097          	auipc	ra,0x0
 29c:	620080e7          	jalr	1568(ra) # 8b8 <printf>
      exit(1);
 2a0:	4505                	li	a0,1
 2a2:	00000097          	auipc	ra,0x0
 2a6:	28e080e7          	jalr	654(ra) # 530 <exit>

00000000000002aa <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 2aa:	1141                	add	sp,sp,-16
 2ac:	e406                	sd	ra,8(sp)
 2ae:	e022                	sd	s0,0(sp)
 2b0:	0800                	add	s0,sp,16
  extern int main();
  main();
 2b2:	00000097          	auipc	ra,0x0
 2b6:	f3a080e7          	jalr	-198(ra) # 1ec <main>
  exit(0);
 2ba:	4501                	li	a0,0
 2bc:	00000097          	auipc	ra,0x0
 2c0:	274080e7          	jalr	628(ra) # 530 <exit>

00000000000002c4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2c4:	1141                	add	sp,sp,-16
 2c6:	e422                	sd	s0,8(sp)
 2c8:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2ca:	87aa                	mv	a5,a0
 2cc:	0585                	add	a1,a1,1
 2ce:	0785                	add	a5,a5,1
 2d0:	fff5c703          	lbu	a4,-1(a1)
 2d4:	fee78fa3          	sb	a4,-1(a5)
 2d8:	fb75                	bnez	a4,2cc <strcpy+0x8>
    ;
  return os;
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	add	sp,sp,16
 2de:	8082                	ret

00000000000002e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2e0:	1141                	add	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 2e6:	00054783          	lbu	a5,0(a0)
 2ea:	cb91                	beqz	a5,2fe <strcmp+0x1e>
 2ec:	0005c703          	lbu	a4,0(a1)
 2f0:	00f71763          	bne	a4,a5,2fe <strcmp+0x1e>
    p++, q++;
 2f4:	0505                	add	a0,a0,1
 2f6:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 2f8:	00054783          	lbu	a5,0(a0)
 2fc:	fbe5                	bnez	a5,2ec <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2fe:	0005c503          	lbu	a0,0(a1)
}
 302:	40a7853b          	subw	a0,a5,a0
 306:	6422                	ld	s0,8(sp)
 308:	0141                	add	sp,sp,16
 30a:	8082                	ret

000000000000030c <strlen>:

uint
strlen(const char *s)
{
 30c:	1141                	add	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 312:	00054783          	lbu	a5,0(a0)
 316:	cf91                	beqz	a5,332 <strlen+0x26>
 318:	0505                	add	a0,a0,1
 31a:	87aa                	mv	a5,a0
 31c:	86be                	mv	a3,a5
 31e:	0785                	add	a5,a5,1
 320:	fff7c703          	lbu	a4,-1(a5)
 324:	ff65                	bnez	a4,31c <strlen+0x10>
 326:	40a6853b          	subw	a0,a3,a0
 32a:	2505                	addw	a0,a0,1
    ;
  return n;
}
 32c:	6422                	ld	s0,8(sp)
 32e:	0141                	add	sp,sp,16
 330:	8082                	ret
  for(n = 0; s[n]; n++)
 332:	4501                	li	a0,0
 334:	bfe5                	j	32c <strlen+0x20>

0000000000000336 <memset>:

void*
memset(void *dst, int c, uint n)
{
 336:	1141                	add	sp,sp,-16
 338:	e422                	sd	s0,8(sp)
 33a:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 33c:	ca19                	beqz	a2,352 <memset+0x1c>
 33e:	87aa                	mv	a5,a0
 340:	1602                	sll	a2,a2,0x20
 342:	9201                	srl	a2,a2,0x20
 344:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 348:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 34c:	0785                	add	a5,a5,1
 34e:	fee79de3          	bne	a5,a4,348 <memset+0x12>
  }
  return dst;
}
 352:	6422                	ld	s0,8(sp)
 354:	0141                	add	sp,sp,16
 356:	8082                	ret

0000000000000358 <strchr>:

char*
strchr(const char *s, char c)
{
 358:	1141                	add	sp,sp,-16
 35a:	e422                	sd	s0,8(sp)
 35c:	0800                	add	s0,sp,16
  for(; *s; s++)
 35e:	00054783          	lbu	a5,0(a0)
 362:	cb99                	beqz	a5,378 <strchr+0x20>
    if(*s == c)
 364:	00f58763          	beq	a1,a5,372 <strchr+0x1a>
  for(; *s; s++)
 368:	0505                	add	a0,a0,1
 36a:	00054783          	lbu	a5,0(a0)
 36e:	fbfd                	bnez	a5,364 <strchr+0xc>
      return (char*)s;
  return 0;
 370:	4501                	li	a0,0
}
 372:	6422                	ld	s0,8(sp)
 374:	0141                	add	sp,sp,16
 376:	8082                	ret
  return 0;
 378:	4501                	li	a0,0
 37a:	bfe5                	j	372 <strchr+0x1a>

000000000000037c <gets>:

char*
gets(char *buf, int max)
{
 37c:	711d                	add	sp,sp,-96
 37e:	ec86                	sd	ra,88(sp)
 380:	e8a2                	sd	s0,80(sp)
 382:	e4a6                	sd	s1,72(sp)
 384:	e0ca                	sd	s2,64(sp)
 386:	fc4e                	sd	s3,56(sp)
 388:	f852                	sd	s4,48(sp)
 38a:	f456                	sd	s5,40(sp)
 38c:	f05a                	sd	s6,32(sp)
 38e:	ec5e                	sd	s7,24(sp)
 390:	1080                	add	s0,sp,96
 392:	8baa                	mv	s7,a0
 394:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 396:	892a                	mv	s2,a0
 398:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 39a:	4aa9                	li	s5,10
 39c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 39e:	89a6                	mv	s3,s1
 3a0:	2485                	addw	s1,s1,1
 3a2:	0344d863          	bge	s1,s4,3d2 <gets+0x56>
    cc = read(0, &c, 1);
 3a6:	4605                	li	a2,1
 3a8:	faf40593          	add	a1,s0,-81
 3ac:	4501                	li	a0,0
 3ae:	00000097          	auipc	ra,0x0
 3b2:	19a080e7          	jalr	410(ra) # 548 <read>
    if(cc < 1)
 3b6:	00a05e63          	blez	a0,3d2 <gets+0x56>
    buf[i++] = c;
 3ba:	faf44783          	lbu	a5,-81(s0)
 3be:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3c2:	01578763          	beq	a5,s5,3d0 <gets+0x54>
 3c6:	0905                	add	s2,s2,1
 3c8:	fd679be3          	bne	a5,s6,39e <gets+0x22>
  for(i=0; i+1 < max; ){
 3cc:	89a6                	mv	s3,s1
 3ce:	a011                	j	3d2 <gets+0x56>
 3d0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3d2:	99de                	add	s3,s3,s7
 3d4:	00098023          	sb	zero,0(s3)
  return buf;
}
 3d8:	855e                	mv	a0,s7
 3da:	60e6                	ld	ra,88(sp)
 3dc:	6446                	ld	s0,80(sp)
 3de:	64a6                	ld	s1,72(sp)
 3e0:	6906                	ld	s2,64(sp)
 3e2:	79e2                	ld	s3,56(sp)
 3e4:	7a42                	ld	s4,48(sp)
 3e6:	7aa2                	ld	s5,40(sp)
 3e8:	7b02                	ld	s6,32(sp)
 3ea:	6be2                	ld	s7,24(sp)
 3ec:	6125                	add	sp,sp,96
 3ee:	8082                	ret

00000000000003f0 <stat>:

int
stat(const char *n, struct stat *st)
{
 3f0:	1101                	add	sp,sp,-32
 3f2:	ec06                	sd	ra,24(sp)
 3f4:	e822                	sd	s0,16(sp)
 3f6:	e426                	sd	s1,8(sp)
 3f8:	e04a                	sd	s2,0(sp)
 3fa:	1000                	add	s0,sp,32
 3fc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3fe:	4581                	li	a1,0
 400:	00000097          	auipc	ra,0x0
 404:	170080e7          	jalr	368(ra) # 570 <open>
  if(fd < 0)
 408:	02054563          	bltz	a0,432 <stat+0x42>
 40c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 40e:	85ca                	mv	a1,s2
 410:	00000097          	auipc	ra,0x0
 414:	178080e7          	jalr	376(ra) # 588 <fstat>
 418:	892a                	mv	s2,a0
  close(fd);
 41a:	8526                	mv	a0,s1
 41c:	00000097          	auipc	ra,0x0
 420:	13c080e7          	jalr	316(ra) # 558 <close>
  return r;
}
 424:	854a                	mv	a0,s2
 426:	60e2                	ld	ra,24(sp)
 428:	6442                	ld	s0,16(sp)
 42a:	64a2                	ld	s1,8(sp)
 42c:	6902                	ld	s2,0(sp)
 42e:	6105                	add	sp,sp,32
 430:	8082                	ret
    return -1;
 432:	597d                	li	s2,-1
 434:	bfc5                	j	424 <stat+0x34>

0000000000000436 <atoi>:

int
atoi(const char *s)
{
 436:	1141                	add	sp,sp,-16
 438:	e422                	sd	s0,8(sp)
 43a:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 43c:	00054683          	lbu	a3,0(a0)
 440:	fd06879b          	addw	a5,a3,-48
 444:	0ff7f793          	zext.b	a5,a5
 448:	4625                	li	a2,9
 44a:	02f66863          	bltu	a2,a5,47a <atoi+0x44>
 44e:	872a                	mv	a4,a0
  n = 0;
 450:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 452:	0705                	add	a4,a4,1
 454:	0025179b          	sllw	a5,a0,0x2
 458:	9fa9                	addw	a5,a5,a0
 45a:	0017979b          	sllw	a5,a5,0x1
 45e:	9fb5                	addw	a5,a5,a3
 460:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 464:	00074683          	lbu	a3,0(a4)
 468:	fd06879b          	addw	a5,a3,-48
 46c:	0ff7f793          	zext.b	a5,a5
 470:	fef671e3          	bgeu	a2,a5,452 <atoi+0x1c>
  return n;
}
 474:	6422                	ld	s0,8(sp)
 476:	0141                	add	sp,sp,16
 478:	8082                	ret
  n = 0;
 47a:	4501                	li	a0,0
 47c:	bfe5                	j	474 <atoi+0x3e>

000000000000047e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 47e:	1141                	add	sp,sp,-16
 480:	e422                	sd	s0,8(sp)
 482:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 484:	02b57463          	bgeu	a0,a1,4ac <memmove+0x2e>
    while(n-- > 0)
 488:	00c05f63          	blez	a2,4a6 <memmove+0x28>
 48c:	1602                	sll	a2,a2,0x20
 48e:	9201                	srl	a2,a2,0x20
 490:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 494:	872a                	mv	a4,a0
      *dst++ = *src++;
 496:	0585                	add	a1,a1,1
 498:	0705                	add	a4,a4,1
 49a:	fff5c683          	lbu	a3,-1(a1)
 49e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4a2:	fee79ae3          	bne	a5,a4,496 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4a6:	6422                	ld	s0,8(sp)
 4a8:	0141                	add	sp,sp,16
 4aa:	8082                	ret
    dst += n;
 4ac:	00c50733          	add	a4,a0,a2
    src += n;
 4b0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4b2:	fec05ae3          	blez	a2,4a6 <memmove+0x28>
 4b6:	fff6079b          	addw	a5,a2,-1
 4ba:	1782                	sll	a5,a5,0x20
 4bc:	9381                	srl	a5,a5,0x20
 4be:	fff7c793          	not	a5,a5
 4c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4c4:	15fd                	add	a1,a1,-1
 4c6:	177d                	add	a4,a4,-1
 4c8:	0005c683          	lbu	a3,0(a1)
 4cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4d0:	fee79ae3          	bne	a5,a4,4c4 <memmove+0x46>
 4d4:	bfc9                	j	4a6 <memmove+0x28>

00000000000004d6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4d6:	1141                	add	sp,sp,-16
 4d8:	e422                	sd	s0,8(sp)
 4da:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 4dc:	ca05                	beqz	a2,50c <memcmp+0x36>
 4de:	fff6069b          	addw	a3,a2,-1
 4e2:	1682                	sll	a3,a3,0x20
 4e4:	9281                	srl	a3,a3,0x20
 4e6:	0685                	add	a3,a3,1
 4e8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 4ea:	00054783          	lbu	a5,0(a0)
 4ee:	0005c703          	lbu	a4,0(a1)
 4f2:	00e79863          	bne	a5,a4,502 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 4f6:	0505                	add	a0,a0,1
    p2++;
 4f8:	0585                	add	a1,a1,1
  while (n-- > 0) {
 4fa:	fed518e3          	bne	a0,a3,4ea <memcmp+0x14>
  }
  return 0;
 4fe:	4501                	li	a0,0
 500:	a019                	j	506 <memcmp+0x30>
      return *p1 - *p2;
 502:	40e7853b          	subw	a0,a5,a4
}
 506:	6422                	ld	s0,8(sp)
 508:	0141                	add	sp,sp,16
 50a:	8082                	ret
  return 0;
 50c:	4501                	li	a0,0
 50e:	bfe5                	j	506 <memcmp+0x30>

0000000000000510 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 510:	1141                	add	sp,sp,-16
 512:	e406                	sd	ra,8(sp)
 514:	e022                	sd	s0,0(sp)
 516:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 518:	00000097          	auipc	ra,0x0
 51c:	f66080e7          	jalr	-154(ra) # 47e <memmove>
}
 520:	60a2                	ld	ra,8(sp)
 522:	6402                	ld	s0,0(sp)
 524:	0141                	add	sp,sp,16
 526:	8082                	ret

0000000000000528 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 528:	4885                	li	a7,1
 ecall
 52a:	00000073          	ecall
 ret
 52e:	8082                	ret

0000000000000530 <exit>:
.global exit
exit:
 li a7, SYS_exit
 530:	4889                	li	a7,2
 ecall
 532:	00000073          	ecall
 ret
 536:	8082                	ret

0000000000000538 <wait>:
.global wait
wait:
 li a7, SYS_wait
 538:	488d                	li	a7,3
 ecall
 53a:	00000073          	ecall
 ret
 53e:	8082                	ret

0000000000000540 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 540:	4891                	li	a7,4
 ecall
 542:	00000073          	ecall
 ret
 546:	8082                	ret

0000000000000548 <read>:
.global read
read:
 li a7, SYS_read
 548:	4895                	li	a7,5
 ecall
 54a:	00000073          	ecall
 ret
 54e:	8082                	ret

0000000000000550 <write>:
.global write
write:
 li a7, SYS_write
 550:	48c1                	li	a7,16
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <close>:
.global close
close:
 li a7, SYS_close
 558:	48d5                	li	a7,21
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <kill>:
.global kill
kill:
 li a7, SYS_kill
 560:	4899                	li	a7,6
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <exec>:
.global exec
exec:
 li a7, SYS_exec
 568:	489d                	li	a7,7
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <open>:
.global open
open:
 li a7, SYS_open
 570:	48bd                	li	a7,15
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 578:	48c5                	li	a7,17
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 580:	48c9                	li	a7,18
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 588:	48a1                	li	a7,8
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <link>:
.global link
link:
 li a7, SYS_link
 590:	48cd                	li	a7,19
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 598:	48d1                	li	a7,20
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5a0:	48a5                	li	a7,9
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5a8:	48a9                	li	a7,10
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5b0:	48ad                	li	a7,11
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5b8:	48b1                	li	a7,12
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5c0:	48b5                	li	a7,13
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5c8:	48b9                	li	a7,14
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 5d0:	48d9                	li	a7,22
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
 5d8:	48dd                	li	a7,23
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 5e0:	48e1                	li	a7,24
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 5e8:	48e5                	li	a7,25
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5f0:	1101                	add	sp,sp,-32
 5f2:	ec06                	sd	ra,24(sp)
 5f4:	e822                	sd	s0,16(sp)
 5f6:	1000                	add	s0,sp,32
 5f8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 5fc:	4605                	li	a2,1
 5fe:	fef40593          	add	a1,s0,-17
 602:	00000097          	auipc	ra,0x0
 606:	f4e080e7          	jalr	-178(ra) # 550 <write>
}
 60a:	60e2                	ld	ra,24(sp)
 60c:	6442                	ld	s0,16(sp)
 60e:	6105                	add	sp,sp,32
 610:	8082                	ret

0000000000000612 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 612:	7139                	add	sp,sp,-64
 614:	fc06                	sd	ra,56(sp)
 616:	f822                	sd	s0,48(sp)
 618:	f426                	sd	s1,40(sp)
 61a:	f04a                	sd	s2,32(sp)
 61c:	ec4e                	sd	s3,24(sp)
 61e:	0080                	add	s0,sp,64
 620:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 622:	c299                	beqz	a3,628 <printint+0x16>
 624:	0805c963          	bltz	a1,6b6 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 628:	2581                	sext.w	a1,a1
  neg = 0;
 62a:	4881                	li	a7,0
 62c:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 630:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 632:	2601                	sext.w	a2,a2
 634:	00000517          	auipc	a0,0x0
 638:	4c450513          	add	a0,a0,1220 # af8 <digits>
 63c:	883a                	mv	a6,a4
 63e:	2705                	addw	a4,a4,1
 640:	02c5f7bb          	remuw	a5,a1,a2
 644:	1782                	sll	a5,a5,0x20
 646:	9381                	srl	a5,a5,0x20
 648:	97aa                	add	a5,a5,a0
 64a:	0007c783          	lbu	a5,0(a5)
 64e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 652:	0005879b          	sext.w	a5,a1
 656:	02c5d5bb          	divuw	a1,a1,a2
 65a:	0685                	add	a3,a3,1
 65c:	fec7f0e3          	bgeu	a5,a2,63c <printint+0x2a>
  if(neg)
 660:	00088c63          	beqz	a7,678 <printint+0x66>
    buf[i++] = '-';
 664:	fd070793          	add	a5,a4,-48
 668:	00878733          	add	a4,a5,s0
 66c:	02d00793          	li	a5,45
 670:	fef70823          	sb	a5,-16(a4)
 674:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 678:	02e05863          	blez	a4,6a8 <printint+0x96>
 67c:	fc040793          	add	a5,s0,-64
 680:	00e78933          	add	s2,a5,a4
 684:	fff78993          	add	s3,a5,-1
 688:	99ba                	add	s3,s3,a4
 68a:	377d                	addw	a4,a4,-1
 68c:	1702                	sll	a4,a4,0x20
 68e:	9301                	srl	a4,a4,0x20
 690:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 694:	fff94583          	lbu	a1,-1(s2)
 698:	8526                	mv	a0,s1
 69a:	00000097          	auipc	ra,0x0
 69e:	f56080e7          	jalr	-170(ra) # 5f0 <putc>
  while(--i >= 0)
 6a2:	197d                	add	s2,s2,-1
 6a4:	ff3918e3          	bne	s2,s3,694 <printint+0x82>
}
 6a8:	70e2                	ld	ra,56(sp)
 6aa:	7442                	ld	s0,48(sp)
 6ac:	74a2                	ld	s1,40(sp)
 6ae:	7902                	ld	s2,32(sp)
 6b0:	69e2                	ld	s3,24(sp)
 6b2:	6121                	add	sp,sp,64
 6b4:	8082                	ret
    x = -xx;
 6b6:	40b005bb          	negw	a1,a1
    neg = 1;
 6ba:	4885                	li	a7,1
    x = -xx;
 6bc:	bf85                	j	62c <printint+0x1a>

00000000000006be <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6be:	715d                	add	sp,sp,-80
 6c0:	e486                	sd	ra,72(sp)
 6c2:	e0a2                	sd	s0,64(sp)
 6c4:	fc26                	sd	s1,56(sp)
 6c6:	f84a                	sd	s2,48(sp)
 6c8:	f44e                	sd	s3,40(sp)
 6ca:	f052                	sd	s4,32(sp)
 6cc:	ec56                	sd	s5,24(sp)
 6ce:	e85a                	sd	s6,16(sp)
 6d0:	e45e                	sd	s7,8(sp)
 6d2:	e062                	sd	s8,0(sp)
 6d4:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6d6:	0005c903          	lbu	s2,0(a1)
 6da:	18090c63          	beqz	s2,872 <vprintf+0x1b4>
 6de:	8aaa                	mv	s5,a0
 6e0:	8bb2                	mv	s7,a2
 6e2:	00158493          	add	s1,a1,1
  state = 0;
 6e6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6e8:	02500a13          	li	s4,37
 6ec:	4b55                	li	s6,21
 6ee:	a839                	j	70c <vprintf+0x4e>
        putc(fd, c);
 6f0:	85ca                	mv	a1,s2
 6f2:	8556                	mv	a0,s5
 6f4:	00000097          	auipc	ra,0x0
 6f8:	efc080e7          	jalr	-260(ra) # 5f0 <putc>
 6fc:	a019                	j	702 <vprintf+0x44>
    } else if(state == '%'){
 6fe:	01498d63          	beq	s3,s4,718 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 702:	0485                	add	s1,s1,1
 704:	fff4c903          	lbu	s2,-1(s1)
 708:	16090563          	beqz	s2,872 <vprintf+0x1b4>
    if(state == 0){
 70c:	fe0999e3          	bnez	s3,6fe <vprintf+0x40>
      if(c == '%'){
 710:	ff4910e3          	bne	s2,s4,6f0 <vprintf+0x32>
        state = '%';
 714:	89d2                	mv	s3,s4
 716:	b7f5                	j	702 <vprintf+0x44>
      if(c == 'd'){
 718:	13490263          	beq	s2,s4,83c <vprintf+0x17e>
 71c:	f9d9079b          	addw	a5,s2,-99
 720:	0ff7f793          	zext.b	a5,a5
 724:	12fb6563          	bltu	s6,a5,84e <vprintf+0x190>
 728:	f9d9079b          	addw	a5,s2,-99
 72c:	0ff7f713          	zext.b	a4,a5
 730:	10eb6f63          	bltu	s6,a4,84e <vprintf+0x190>
 734:	00271793          	sll	a5,a4,0x2
 738:	00000717          	auipc	a4,0x0
 73c:	36870713          	add	a4,a4,872 # aa0 <malloc+0x130>
 740:	97ba                	add	a5,a5,a4
 742:	439c                	lw	a5,0(a5)
 744:	97ba                	add	a5,a5,a4
 746:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 748:	008b8913          	add	s2,s7,8
 74c:	4685                	li	a3,1
 74e:	4629                	li	a2,10
 750:	000ba583          	lw	a1,0(s7)
 754:	8556                	mv	a0,s5
 756:	00000097          	auipc	ra,0x0
 75a:	ebc080e7          	jalr	-324(ra) # 612 <printint>
 75e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 760:	4981                	li	s3,0
 762:	b745                	j	702 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 764:	008b8913          	add	s2,s7,8
 768:	4681                	li	a3,0
 76a:	4629                	li	a2,10
 76c:	000ba583          	lw	a1,0(s7)
 770:	8556                	mv	a0,s5
 772:	00000097          	auipc	ra,0x0
 776:	ea0080e7          	jalr	-352(ra) # 612 <printint>
 77a:	8bca                	mv	s7,s2
      state = 0;
 77c:	4981                	li	s3,0
 77e:	b751                	j	702 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 780:	008b8913          	add	s2,s7,8
 784:	4681                	li	a3,0
 786:	4641                	li	a2,16
 788:	000ba583          	lw	a1,0(s7)
 78c:	8556                	mv	a0,s5
 78e:	00000097          	auipc	ra,0x0
 792:	e84080e7          	jalr	-380(ra) # 612 <printint>
 796:	8bca                	mv	s7,s2
      state = 0;
 798:	4981                	li	s3,0
 79a:	b7a5                	j	702 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 79c:	008b8c13          	add	s8,s7,8
 7a0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7a4:	03000593          	li	a1,48
 7a8:	8556                	mv	a0,s5
 7aa:	00000097          	auipc	ra,0x0
 7ae:	e46080e7          	jalr	-442(ra) # 5f0 <putc>
  putc(fd, 'x');
 7b2:	07800593          	li	a1,120
 7b6:	8556                	mv	a0,s5
 7b8:	00000097          	auipc	ra,0x0
 7bc:	e38080e7          	jalr	-456(ra) # 5f0 <putc>
 7c0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7c2:	00000b97          	auipc	s7,0x0
 7c6:	336b8b93          	add	s7,s7,822 # af8 <digits>
 7ca:	03c9d793          	srl	a5,s3,0x3c
 7ce:	97de                	add	a5,a5,s7
 7d0:	0007c583          	lbu	a1,0(a5)
 7d4:	8556                	mv	a0,s5
 7d6:	00000097          	auipc	ra,0x0
 7da:	e1a080e7          	jalr	-486(ra) # 5f0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7de:	0992                	sll	s3,s3,0x4
 7e0:	397d                	addw	s2,s2,-1
 7e2:	fe0914e3          	bnez	s2,7ca <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 7e6:	8be2                	mv	s7,s8
      state = 0;
 7e8:	4981                	li	s3,0
 7ea:	bf21                	j	702 <vprintf+0x44>
        s = va_arg(ap, char*);
 7ec:	008b8993          	add	s3,s7,8
 7f0:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 7f4:	02090163          	beqz	s2,816 <vprintf+0x158>
        while(*s != 0){
 7f8:	00094583          	lbu	a1,0(s2)
 7fc:	c9a5                	beqz	a1,86c <vprintf+0x1ae>
          putc(fd, *s);
 7fe:	8556                	mv	a0,s5
 800:	00000097          	auipc	ra,0x0
 804:	df0080e7          	jalr	-528(ra) # 5f0 <putc>
          s++;
 808:	0905                	add	s2,s2,1
        while(*s != 0){
 80a:	00094583          	lbu	a1,0(s2)
 80e:	f9e5                	bnez	a1,7fe <vprintf+0x140>
        s = va_arg(ap, char*);
 810:	8bce                	mv	s7,s3
      state = 0;
 812:	4981                	li	s3,0
 814:	b5fd                	j	702 <vprintf+0x44>
          s = "(null)";
 816:	00000917          	auipc	s2,0x0
 81a:	28290913          	add	s2,s2,642 # a98 <malloc+0x128>
        while(*s != 0){
 81e:	02800593          	li	a1,40
 822:	bff1                	j	7fe <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 824:	008b8913          	add	s2,s7,8
 828:	000bc583          	lbu	a1,0(s7)
 82c:	8556                	mv	a0,s5
 82e:	00000097          	auipc	ra,0x0
 832:	dc2080e7          	jalr	-574(ra) # 5f0 <putc>
 836:	8bca                	mv	s7,s2
      state = 0;
 838:	4981                	li	s3,0
 83a:	b5e1                	j	702 <vprintf+0x44>
        putc(fd, c);
 83c:	02500593          	li	a1,37
 840:	8556                	mv	a0,s5
 842:	00000097          	auipc	ra,0x0
 846:	dae080e7          	jalr	-594(ra) # 5f0 <putc>
      state = 0;
 84a:	4981                	li	s3,0
 84c:	bd5d                	j	702 <vprintf+0x44>
        putc(fd, '%');
 84e:	02500593          	li	a1,37
 852:	8556                	mv	a0,s5
 854:	00000097          	auipc	ra,0x0
 858:	d9c080e7          	jalr	-612(ra) # 5f0 <putc>
        putc(fd, c);
 85c:	85ca                	mv	a1,s2
 85e:	8556                	mv	a0,s5
 860:	00000097          	auipc	ra,0x0
 864:	d90080e7          	jalr	-624(ra) # 5f0 <putc>
      state = 0;
 868:	4981                	li	s3,0
 86a:	bd61                	j	702 <vprintf+0x44>
        s = va_arg(ap, char*);
 86c:	8bce                	mv	s7,s3
      state = 0;
 86e:	4981                	li	s3,0
 870:	bd49                	j	702 <vprintf+0x44>
    }
  }
}
 872:	60a6                	ld	ra,72(sp)
 874:	6406                	ld	s0,64(sp)
 876:	74e2                	ld	s1,56(sp)
 878:	7942                	ld	s2,48(sp)
 87a:	79a2                	ld	s3,40(sp)
 87c:	7a02                	ld	s4,32(sp)
 87e:	6ae2                	ld	s5,24(sp)
 880:	6b42                	ld	s6,16(sp)
 882:	6ba2                	ld	s7,8(sp)
 884:	6c02                	ld	s8,0(sp)
 886:	6161                	add	sp,sp,80
 888:	8082                	ret

000000000000088a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 88a:	715d                	add	sp,sp,-80
 88c:	ec06                	sd	ra,24(sp)
 88e:	e822                	sd	s0,16(sp)
 890:	1000                	add	s0,sp,32
 892:	e010                	sd	a2,0(s0)
 894:	e414                	sd	a3,8(s0)
 896:	e818                	sd	a4,16(s0)
 898:	ec1c                	sd	a5,24(s0)
 89a:	03043023          	sd	a6,32(s0)
 89e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8a2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8a6:	8622                	mv	a2,s0
 8a8:	00000097          	auipc	ra,0x0
 8ac:	e16080e7          	jalr	-490(ra) # 6be <vprintf>
}
 8b0:	60e2                	ld	ra,24(sp)
 8b2:	6442                	ld	s0,16(sp)
 8b4:	6161                	add	sp,sp,80
 8b6:	8082                	ret

00000000000008b8 <printf>:

void
printf(const char *fmt, ...)
{
 8b8:	711d                	add	sp,sp,-96
 8ba:	ec06                	sd	ra,24(sp)
 8bc:	e822                	sd	s0,16(sp)
 8be:	1000                	add	s0,sp,32
 8c0:	e40c                	sd	a1,8(s0)
 8c2:	e810                	sd	a2,16(s0)
 8c4:	ec14                	sd	a3,24(s0)
 8c6:	f018                	sd	a4,32(s0)
 8c8:	f41c                	sd	a5,40(s0)
 8ca:	03043823          	sd	a6,48(s0)
 8ce:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8d2:	00840613          	add	a2,s0,8
 8d6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8da:	85aa                	mv	a1,a0
 8dc:	4505                	li	a0,1
 8de:	00000097          	auipc	ra,0x0
 8e2:	de0080e7          	jalr	-544(ra) # 6be <vprintf>
}
 8e6:	60e2                	ld	ra,24(sp)
 8e8:	6442                	ld	s0,16(sp)
 8ea:	6125                	add	sp,sp,96
 8ec:	8082                	ret

00000000000008ee <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8ee:	1141                	add	sp,sp,-16
 8f0:	e422                	sd	s0,8(sp)
 8f2:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8f4:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8f8:	00000797          	auipc	a5,0x0
 8fc:	7087b783          	ld	a5,1800(a5) # 1000 <freep>
 900:	a02d                	j	92a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 902:	4618                	lw	a4,8(a2)
 904:	9f2d                	addw	a4,a4,a1
 906:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 90a:	6398                	ld	a4,0(a5)
 90c:	6310                	ld	a2,0(a4)
 90e:	a83d                	j	94c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 910:	ff852703          	lw	a4,-8(a0)
 914:	9f31                	addw	a4,a4,a2
 916:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 918:	ff053683          	ld	a3,-16(a0)
 91c:	a091                	j	960 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 91e:	6398                	ld	a4,0(a5)
 920:	00e7e463          	bltu	a5,a4,928 <free+0x3a>
 924:	00e6ea63          	bltu	a3,a4,938 <free+0x4a>
{
 928:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 92a:	fed7fae3          	bgeu	a5,a3,91e <free+0x30>
 92e:	6398                	ld	a4,0(a5)
 930:	00e6e463          	bltu	a3,a4,938 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 934:	fee7eae3          	bltu	a5,a4,928 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 938:	ff852583          	lw	a1,-8(a0)
 93c:	6390                	ld	a2,0(a5)
 93e:	02059813          	sll	a6,a1,0x20
 942:	01c85713          	srl	a4,a6,0x1c
 946:	9736                	add	a4,a4,a3
 948:	fae60de3          	beq	a2,a4,902 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 94c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 950:	4790                	lw	a2,8(a5)
 952:	02061593          	sll	a1,a2,0x20
 956:	01c5d713          	srl	a4,a1,0x1c
 95a:	973e                	add	a4,a4,a5
 95c:	fae68ae3          	beq	a3,a4,910 <free+0x22>
    p->s.ptr = bp->s.ptr;
 960:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 962:	00000717          	auipc	a4,0x0
 966:	68f73f23          	sd	a5,1694(a4) # 1000 <freep>
}
 96a:	6422                	ld	s0,8(sp)
 96c:	0141                	add	sp,sp,16
 96e:	8082                	ret

0000000000000970 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 970:	7139                	add	sp,sp,-64
 972:	fc06                	sd	ra,56(sp)
 974:	f822                	sd	s0,48(sp)
 976:	f426                	sd	s1,40(sp)
 978:	f04a                	sd	s2,32(sp)
 97a:	ec4e                	sd	s3,24(sp)
 97c:	e852                	sd	s4,16(sp)
 97e:	e456                	sd	s5,8(sp)
 980:	e05a                	sd	s6,0(sp)
 982:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 984:	02051493          	sll	s1,a0,0x20
 988:	9081                	srl	s1,s1,0x20
 98a:	04bd                	add	s1,s1,15
 98c:	8091                	srl	s1,s1,0x4
 98e:	0014899b          	addw	s3,s1,1
 992:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 994:	00000517          	auipc	a0,0x0
 998:	66c53503          	ld	a0,1644(a0) # 1000 <freep>
 99c:	c515                	beqz	a0,9c8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 99e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9a0:	4798                	lw	a4,8(a5)
 9a2:	02977f63          	bgeu	a4,s1,9e0 <malloc+0x70>
  if(nu < 4096)
 9a6:	8a4e                	mv	s4,s3
 9a8:	0009871b          	sext.w	a4,s3
 9ac:	6685                	lui	a3,0x1
 9ae:	00d77363          	bgeu	a4,a3,9b4 <malloc+0x44>
 9b2:	6a05                	lui	s4,0x1
 9b4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9b8:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9bc:	00000917          	auipc	s2,0x0
 9c0:	64490913          	add	s2,s2,1604 # 1000 <freep>
  if(p == (char*)-1)
 9c4:	5afd                	li	s5,-1
 9c6:	a895                	j	a3a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 9c8:	00001797          	auipc	a5,0x1
 9cc:	a4878793          	add	a5,a5,-1464 # 1410 <base>
 9d0:	00000717          	auipc	a4,0x0
 9d4:	62f73823          	sd	a5,1584(a4) # 1000 <freep>
 9d8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9da:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9de:	b7e1                	j	9a6 <malloc+0x36>
      if(p->s.size == nunits)
 9e0:	02e48c63          	beq	s1,a4,a18 <malloc+0xa8>
        p->s.size -= nunits;
 9e4:	4137073b          	subw	a4,a4,s3
 9e8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9ea:	02071693          	sll	a3,a4,0x20
 9ee:	01c6d713          	srl	a4,a3,0x1c
 9f2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9f4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9f8:	00000717          	auipc	a4,0x0
 9fc:	60a73423          	sd	a0,1544(a4) # 1000 <freep>
      return (void*)(p + 1);
 a00:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a04:	70e2                	ld	ra,56(sp)
 a06:	7442                	ld	s0,48(sp)
 a08:	74a2                	ld	s1,40(sp)
 a0a:	7902                	ld	s2,32(sp)
 a0c:	69e2                	ld	s3,24(sp)
 a0e:	6a42                	ld	s4,16(sp)
 a10:	6aa2                	ld	s5,8(sp)
 a12:	6b02                	ld	s6,0(sp)
 a14:	6121                	add	sp,sp,64
 a16:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a18:	6398                	ld	a4,0(a5)
 a1a:	e118                	sd	a4,0(a0)
 a1c:	bff1                	j	9f8 <malloc+0x88>
  hp->s.size = nu;
 a1e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a22:	0541                	add	a0,a0,16
 a24:	00000097          	auipc	ra,0x0
 a28:	eca080e7          	jalr	-310(ra) # 8ee <free>
  return freep;
 a2c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a30:	d971                	beqz	a0,a04 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a32:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a34:	4798                	lw	a4,8(a5)
 a36:	fa9775e3          	bgeu	a4,s1,9e0 <malloc+0x70>
    if(p == freep)
 a3a:	00093703          	ld	a4,0(s2)
 a3e:	853e                	mv	a0,a5
 a40:	fef719e3          	bne	a4,a5,a32 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a44:	8552                	mv	a0,s4
 a46:	00000097          	auipc	ra,0x0
 a4a:	b72080e7          	jalr	-1166(ra) # 5b8 <sbrk>
  if(p == (char*)-1)
 a4e:	fd5518e3          	bne	a0,s5,a1e <malloc+0xae>
        return 0;
 a52:	4501                	li	a0,0
 a54:	bf45                	j	a04 <malloc+0x94>
