
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
   0:	7179                	add	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	add	s0,sp,48
   e:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
  10:	00000097          	auipc	ra,0x0
  14:	324080e7          	jalr	804(ra) # 334 <strlen>
  18:	02051793          	sll	a5,a0,0x20
  1c:	9381                	srl	a5,a5,0x20
  1e:	97a6                	add	a5,a5,s1
  20:	02f00693          	li	a3,47
  24:	0097e963          	bltu	a5,s1,36 <fmtname+0x36>
  28:	0007c703          	lbu	a4,0(a5)
  2c:	00d70563          	beq	a4,a3,36 <fmtname+0x36>
  30:	17fd                	add	a5,a5,-1
  32:	fe97fbe3          	bgeu	a5,s1,28 <fmtname+0x28>
    ;
  p++;
  36:	00178493          	add	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  3a:	8526                	mv	a0,s1
  3c:	00000097          	auipc	ra,0x0
  40:	2f8080e7          	jalr	760(ra) # 334 <strlen>
  44:	2501                	sext.w	a0,a0
  46:	47b5                	li	a5,13
  48:	00a7fa63          	bgeu	a5,a0,5c <fmtname+0x5c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  return buf;
}
  4c:	8526                	mv	a0,s1
  4e:	70a2                	ld	ra,40(sp)
  50:	7402                	ld	s0,32(sp)
  52:	64e2                	ld	s1,24(sp)
  54:	6942                	ld	s2,16(sp)
  56:	69a2                	ld	s3,8(sp)
  58:	6145                	add	sp,sp,48
  5a:	8082                	ret
  memmove(buf, p, strlen(p));
  5c:	8526                	mv	a0,s1
  5e:	00000097          	auipc	ra,0x0
  62:	2d6080e7          	jalr	726(ra) # 334 <strlen>
  66:	00001997          	auipc	s3,0x1
  6a:	faa98993          	add	s3,s3,-86 # 1010 <buf.0>
  6e:	0005061b          	sext.w	a2,a0
  72:	85a6                	mv	a1,s1
  74:	854e                	mv	a0,s3
  76:	00000097          	auipc	ra,0x0
  7a:	430080e7          	jalr	1072(ra) # 4a6 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  7e:	8526                	mv	a0,s1
  80:	00000097          	auipc	ra,0x0
  84:	2b4080e7          	jalr	692(ra) # 334 <strlen>
  88:	0005091b          	sext.w	s2,a0
  8c:	8526                	mv	a0,s1
  8e:	00000097          	auipc	ra,0x0
  92:	2a6080e7          	jalr	678(ra) # 334 <strlen>
  96:	1902                	sll	s2,s2,0x20
  98:	02095913          	srl	s2,s2,0x20
  9c:	4639                	li	a2,14
  9e:	9e09                	subw	a2,a2,a0
  a0:	02000593          	li	a1,32
  a4:	01298533          	add	a0,s3,s2
  a8:	00000097          	auipc	ra,0x0
  ac:	2b6080e7          	jalr	694(ra) # 35e <memset>
  return buf;
  b0:	84ce                	mv	s1,s3
  b2:	bf69                	j	4c <fmtname+0x4c>

00000000000000b4 <ls>:

void
ls(char *path)
{
  b4:	d9010113          	add	sp,sp,-624
  b8:	26113423          	sd	ra,616(sp)
  bc:	26813023          	sd	s0,608(sp)
  c0:	24913c23          	sd	s1,600(sp)
  c4:	25213823          	sd	s2,592(sp)
  c8:	25313423          	sd	s3,584(sp)
  cc:	25413023          	sd	s4,576(sp)
  d0:	23513c23          	sd	s5,568(sp)
  d4:	1c80                	add	s0,sp,624
  d6:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  d8:	4581                	li	a1,0
  da:	00000097          	auipc	ra,0x0
  de:	4be080e7          	jalr	1214(ra) # 598 <open>
  e2:	06054f63          	bltz	a0,160 <ls+0xac>
  e6:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  e8:	d9840593          	add	a1,s0,-616
  ec:	00000097          	auipc	ra,0x0
  f0:	4c4080e7          	jalr	1220(ra) # 5b0 <fstat>
  f4:	08054163          	bltz	a0,176 <ls+0xc2>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  f8:	da041783          	lh	a5,-608(s0)
  fc:	4705                	li	a4,1
  fe:	08e78c63          	beq	a5,a4,196 <ls+0xe2>
 102:	37f9                	addw	a5,a5,-2
 104:	17c2                	sll	a5,a5,0x30
 106:	93c1                	srl	a5,a5,0x30
 108:	02f76663          	bltu	a4,a5,134 <ls+0x80>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %l\n", fmtname(path), st.type, st.ino, st.size);
 10c:	854a                	mv	a0,s2
 10e:	00000097          	auipc	ra,0x0
 112:	ef2080e7          	jalr	-270(ra) # 0 <fmtname>
 116:	85aa                	mv	a1,a0
 118:	da843703          	ld	a4,-600(s0)
 11c:	d9c42683          	lw	a3,-612(s0)
 120:	da041603          	lh	a2,-608(s0)
 124:	00001517          	auipc	a0,0x1
 128:	97c50513          	add	a0,a0,-1668 # aa0 <malloc+0x120>
 12c:	00000097          	auipc	ra,0x0
 130:	79c080e7          	jalr	1948(ra) # 8c8 <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
  }
  close(fd);
 134:	8526                	mv	a0,s1
 136:	00000097          	auipc	ra,0x0
 13a:	44a080e7          	jalr	1098(ra) # 580 <close>
}
 13e:	26813083          	ld	ra,616(sp)
 142:	26013403          	ld	s0,608(sp)
 146:	25813483          	ld	s1,600(sp)
 14a:	25013903          	ld	s2,592(sp)
 14e:	24813983          	ld	s3,584(sp)
 152:	24013a03          	ld	s4,576(sp)
 156:	23813a83          	ld	s5,568(sp)
 15a:	27010113          	add	sp,sp,624
 15e:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 160:	864a                	mv	a2,s2
 162:	00001597          	auipc	a1,0x1
 166:	90e58593          	add	a1,a1,-1778 # a70 <malloc+0xf0>
 16a:	4509                	li	a0,2
 16c:	00000097          	auipc	ra,0x0
 170:	72e080e7          	jalr	1838(ra) # 89a <fprintf>
    return;
 174:	b7e9                	j	13e <ls+0x8a>
    fprintf(2, "ls: cannot stat %s\n", path);
 176:	864a                	mv	a2,s2
 178:	00001597          	auipc	a1,0x1
 17c:	91058593          	add	a1,a1,-1776 # a88 <malloc+0x108>
 180:	4509                	li	a0,2
 182:	00000097          	auipc	ra,0x0
 186:	718080e7          	jalr	1816(ra) # 89a <fprintf>
    close(fd);
 18a:	8526                	mv	a0,s1
 18c:	00000097          	auipc	ra,0x0
 190:	3f4080e7          	jalr	1012(ra) # 580 <close>
    return;
 194:	b76d                	j	13e <ls+0x8a>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 196:	854a                	mv	a0,s2
 198:	00000097          	auipc	ra,0x0
 19c:	19c080e7          	jalr	412(ra) # 334 <strlen>
 1a0:	2541                	addw	a0,a0,16
 1a2:	20000793          	li	a5,512
 1a6:	00a7fb63          	bgeu	a5,a0,1bc <ls+0x108>
      printf("ls: path too long\n");
 1aa:	00001517          	auipc	a0,0x1
 1ae:	90650513          	add	a0,a0,-1786 # ab0 <malloc+0x130>
 1b2:	00000097          	auipc	ra,0x0
 1b6:	716080e7          	jalr	1814(ra) # 8c8 <printf>
      break;
 1ba:	bfad                	j	134 <ls+0x80>
    strcpy(buf, path);
 1bc:	85ca                	mv	a1,s2
 1be:	dc040513          	add	a0,s0,-576
 1c2:	00000097          	auipc	ra,0x0
 1c6:	12a080e7          	jalr	298(ra) # 2ec <strcpy>
    p = buf+strlen(buf);
 1ca:	dc040513          	add	a0,s0,-576
 1ce:	00000097          	auipc	ra,0x0
 1d2:	166080e7          	jalr	358(ra) # 334 <strlen>
 1d6:	1502                	sll	a0,a0,0x20
 1d8:	9101                	srl	a0,a0,0x20
 1da:	dc040793          	add	a5,s0,-576
 1de:	00a78933          	add	s2,a5,a0
    *p++ = '/';
 1e2:	00190993          	add	s3,s2,1
 1e6:	02f00793          	li	a5,47
 1ea:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 1ee:	00001a17          	auipc	s4,0x1
 1f2:	8daa0a13          	add	s4,s4,-1830 # ac8 <malloc+0x148>
        printf("ls: cannot stat %s\n", buf);
 1f6:	00001a97          	auipc	s5,0x1
 1fa:	892a8a93          	add	s5,s5,-1902 # a88 <malloc+0x108>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1fe:	a801                	j	20e <ls+0x15a>
        printf("ls: cannot stat %s\n", buf);
 200:	dc040593          	add	a1,s0,-576
 204:	8556                	mv	a0,s5
 206:	00000097          	auipc	ra,0x0
 20a:	6c2080e7          	jalr	1730(ra) # 8c8 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 20e:	4641                	li	a2,16
 210:	db040593          	add	a1,s0,-592
 214:	8526                	mv	a0,s1
 216:	00000097          	auipc	ra,0x0
 21a:	35a080e7          	jalr	858(ra) # 570 <read>
 21e:	47c1                	li	a5,16
 220:	f0f51ae3          	bne	a0,a5,134 <ls+0x80>
      if(de.inum == 0)
 224:	db045783          	lhu	a5,-592(s0)
 228:	d3fd                	beqz	a5,20e <ls+0x15a>
      memmove(p, de.name, DIRSIZ);
 22a:	4639                	li	a2,14
 22c:	db240593          	add	a1,s0,-590
 230:	854e                	mv	a0,s3
 232:	00000097          	auipc	ra,0x0
 236:	274080e7          	jalr	628(ra) # 4a6 <memmove>
      p[DIRSIZ] = 0;
 23a:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 23e:	d9840593          	add	a1,s0,-616
 242:	dc040513          	add	a0,s0,-576
 246:	00000097          	auipc	ra,0x0
 24a:	1d2080e7          	jalr	466(ra) # 418 <stat>
 24e:	fa0549e3          	bltz	a0,200 <ls+0x14c>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 252:	dc040513          	add	a0,s0,-576
 256:	00000097          	auipc	ra,0x0
 25a:	daa080e7          	jalr	-598(ra) # 0 <fmtname>
 25e:	85aa                	mv	a1,a0
 260:	da843703          	ld	a4,-600(s0)
 264:	d9c42683          	lw	a3,-612(s0)
 268:	da041603          	lh	a2,-608(s0)
 26c:	8552                	mv	a0,s4
 26e:	00000097          	auipc	ra,0x0
 272:	65a080e7          	jalr	1626(ra) # 8c8 <printf>
 276:	bf61                	j	20e <ls+0x15a>

0000000000000278 <main>:

int
main(int argc, char *argv[])
{
 278:	1101                	add	sp,sp,-32
 27a:	ec06                	sd	ra,24(sp)
 27c:	e822                	sd	s0,16(sp)
 27e:	e426                	sd	s1,8(sp)
 280:	e04a                	sd	s2,0(sp)
 282:	1000                	add	s0,sp,32
  int i;

  if(argc < 2){
 284:	4785                	li	a5,1
 286:	02a7d963          	bge	a5,a0,2b8 <main+0x40>
 28a:	00858493          	add	s1,a1,8
 28e:	ffe5091b          	addw	s2,a0,-2
 292:	02091793          	sll	a5,s2,0x20
 296:	01d7d913          	srl	s2,a5,0x1d
 29a:	05c1                	add	a1,a1,16
 29c:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 29e:	6088                	ld	a0,0(s1)
 2a0:	00000097          	auipc	ra,0x0
 2a4:	e14080e7          	jalr	-492(ra) # b4 <ls>
  for(i=1; i<argc; i++)
 2a8:	04a1                	add	s1,s1,8
 2aa:	ff249ae3          	bne	s1,s2,29e <main+0x26>
  exit(0);
 2ae:	4501                	li	a0,0
 2b0:	00000097          	auipc	ra,0x0
 2b4:	2a8080e7          	jalr	680(ra) # 558 <exit>
    ls(".");
 2b8:	00001517          	auipc	a0,0x1
 2bc:	82050513          	add	a0,a0,-2016 # ad8 <malloc+0x158>
 2c0:	00000097          	auipc	ra,0x0
 2c4:	df4080e7          	jalr	-524(ra) # b4 <ls>
    exit(0);
 2c8:	4501                	li	a0,0
 2ca:	00000097          	auipc	ra,0x0
 2ce:	28e080e7          	jalr	654(ra) # 558 <exit>

00000000000002d2 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 2d2:	1141                	add	sp,sp,-16
 2d4:	e406                	sd	ra,8(sp)
 2d6:	e022                	sd	s0,0(sp)
 2d8:	0800                	add	s0,sp,16
  extern int main();
  main();
 2da:	00000097          	auipc	ra,0x0
 2de:	f9e080e7          	jalr	-98(ra) # 278 <main>
  exit(0);
 2e2:	4501                	li	a0,0
 2e4:	00000097          	auipc	ra,0x0
 2e8:	274080e7          	jalr	628(ra) # 558 <exit>

00000000000002ec <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2ec:	1141                	add	sp,sp,-16
 2ee:	e422                	sd	s0,8(sp)
 2f0:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2f2:	87aa                	mv	a5,a0
 2f4:	0585                	add	a1,a1,1
 2f6:	0785                	add	a5,a5,1
 2f8:	fff5c703          	lbu	a4,-1(a1)
 2fc:	fee78fa3          	sb	a4,-1(a5)
 300:	fb75                	bnez	a4,2f4 <strcpy+0x8>
    ;
  return os;
}
 302:	6422                	ld	s0,8(sp)
 304:	0141                	add	sp,sp,16
 306:	8082                	ret

0000000000000308 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 308:	1141                	add	sp,sp,-16
 30a:	e422                	sd	s0,8(sp)
 30c:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 30e:	00054783          	lbu	a5,0(a0)
 312:	cb91                	beqz	a5,326 <strcmp+0x1e>
 314:	0005c703          	lbu	a4,0(a1)
 318:	00f71763          	bne	a4,a5,326 <strcmp+0x1e>
    p++, q++;
 31c:	0505                	add	a0,a0,1
 31e:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 320:	00054783          	lbu	a5,0(a0)
 324:	fbe5                	bnez	a5,314 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 326:	0005c503          	lbu	a0,0(a1)
}
 32a:	40a7853b          	subw	a0,a5,a0
 32e:	6422                	ld	s0,8(sp)
 330:	0141                	add	sp,sp,16
 332:	8082                	ret

0000000000000334 <strlen>:

uint
strlen(const char *s)
{
 334:	1141                	add	sp,sp,-16
 336:	e422                	sd	s0,8(sp)
 338:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 33a:	00054783          	lbu	a5,0(a0)
 33e:	cf91                	beqz	a5,35a <strlen+0x26>
 340:	0505                	add	a0,a0,1
 342:	87aa                	mv	a5,a0
 344:	86be                	mv	a3,a5
 346:	0785                	add	a5,a5,1
 348:	fff7c703          	lbu	a4,-1(a5)
 34c:	ff65                	bnez	a4,344 <strlen+0x10>
 34e:	40a6853b          	subw	a0,a3,a0
 352:	2505                	addw	a0,a0,1
    ;
  return n;
}
 354:	6422                	ld	s0,8(sp)
 356:	0141                	add	sp,sp,16
 358:	8082                	ret
  for(n = 0; s[n]; n++)
 35a:	4501                	li	a0,0
 35c:	bfe5                	j	354 <strlen+0x20>

000000000000035e <memset>:

void*
memset(void *dst, int c, uint n)
{
 35e:	1141                	add	sp,sp,-16
 360:	e422                	sd	s0,8(sp)
 362:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 364:	ca19                	beqz	a2,37a <memset+0x1c>
 366:	87aa                	mv	a5,a0
 368:	1602                	sll	a2,a2,0x20
 36a:	9201                	srl	a2,a2,0x20
 36c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 370:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 374:	0785                	add	a5,a5,1
 376:	fee79de3          	bne	a5,a4,370 <memset+0x12>
  }
  return dst;
}
 37a:	6422                	ld	s0,8(sp)
 37c:	0141                	add	sp,sp,16
 37e:	8082                	ret

0000000000000380 <strchr>:

char*
strchr(const char *s, char c)
{
 380:	1141                	add	sp,sp,-16
 382:	e422                	sd	s0,8(sp)
 384:	0800                	add	s0,sp,16
  for(; *s; s++)
 386:	00054783          	lbu	a5,0(a0)
 38a:	cb99                	beqz	a5,3a0 <strchr+0x20>
    if(*s == c)
 38c:	00f58763          	beq	a1,a5,39a <strchr+0x1a>
  for(; *s; s++)
 390:	0505                	add	a0,a0,1
 392:	00054783          	lbu	a5,0(a0)
 396:	fbfd                	bnez	a5,38c <strchr+0xc>
      return (char*)s;
  return 0;
 398:	4501                	li	a0,0
}
 39a:	6422                	ld	s0,8(sp)
 39c:	0141                	add	sp,sp,16
 39e:	8082                	ret
  return 0;
 3a0:	4501                	li	a0,0
 3a2:	bfe5                	j	39a <strchr+0x1a>

00000000000003a4 <gets>:

char*
gets(char *buf, int max)
{
 3a4:	711d                	add	sp,sp,-96
 3a6:	ec86                	sd	ra,88(sp)
 3a8:	e8a2                	sd	s0,80(sp)
 3aa:	e4a6                	sd	s1,72(sp)
 3ac:	e0ca                	sd	s2,64(sp)
 3ae:	fc4e                	sd	s3,56(sp)
 3b0:	f852                	sd	s4,48(sp)
 3b2:	f456                	sd	s5,40(sp)
 3b4:	f05a                	sd	s6,32(sp)
 3b6:	ec5e                	sd	s7,24(sp)
 3b8:	1080                	add	s0,sp,96
 3ba:	8baa                	mv	s7,a0
 3bc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3be:	892a                	mv	s2,a0
 3c0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3c2:	4aa9                	li	s5,10
 3c4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3c6:	89a6                	mv	s3,s1
 3c8:	2485                	addw	s1,s1,1
 3ca:	0344d863          	bge	s1,s4,3fa <gets+0x56>
    cc = read(0, &c, 1);
 3ce:	4605                	li	a2,1
 3d0:	faf40593          	add	a1,s0,-81
 3d4:	4501                	li	a0,0
 3d6:	00000097          	auipc	ra,0x0
 3da:	19a080e7          	jalr	410(ra) # 570 <read>
    if(cc < 1)
 3de:	00a05e63          	blez	a0,3fa <gets+0x56>
    buf[i++] = c;
 3e2:	faf44783          	lbu	a5,-81(s0)
 3e6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3ea:	01578763          	beq	a5,s5,3f8 <gets+0x54>
 3ee:	0905                	add	s2,s2,1
 3f0:	fd679be3          	bne	a5,s6,3c6 <gets+0x22>
  for(i=0; i+1 < max; ){
 3f4:	89a6                	mv	s3,s1
 3f6:	a011                	j	3fa <gets+0x56>
 3f8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 3fa:	99de                	add	s3,s3,s7
 3fc:	00098023          	sb	zero,0(s3)
  return buf;
}
 400:	855e                	mv	a0,s7
 402:	60e6                	ld	ra,88(sp)
 404:	6446                	ld	s0,80(sp)
 406:	64a6                	ld	s1,72(sp)
 408:	6906                	ld	s2,64(sp)
 40a:	79e2                	ld	s3,56(sp)
 40c:	7a42                	ld	s4,48(sp)
 40e:	7aa2                	ld	s5,40(sp)
 410:	7b02                	ld	s6,32(sp)
 412:	6be2                	ld	s7,24(sp)
 414:	6125                	add	sp,sp,96
 416:	8082                	ret

0000000000000418 <stat>:

int
stat(const char *n, struct stat *st)
{
 418:	1101                	add	sp,sp,-32
 41a:	ec06                	sd	ra,24(sp)
 41c:	e822                	sd	s0,16(sp)
 41e:	e426                	sd	s1,8(sp)
 420:	e04a                	sd	s2,0(sp)
 422:	1000                	add	s0,sp,32
 424:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 426:	4581                	li	a1,0
 428:	00000097          	auipc	ra,0x0
 42c:	170080e7          	jalr	368(ra) # 598 <open>
  if(fd < 0)
 430:	02054563          	bltz	a0,45a <stat+0x42>
 434:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 436:	85ca                	mv	a1,s2
 438:	00000097          	auipc	ra,0x0
 43c:	178080e7          	jalr	376(ra) # 5b0 <fstat>
 440:	892a                	mv	s2,a0
  close(fd);
 442:	8526                	mv	a0,s1
 444:	00000097          	auipc	ra,0x0
 448:	13c080e7          	jalr	316(ra) # 580 <close>
  return r;
}
 44c:	854a                	mv	a0,s2
 44e:	60e2                	ld	ra,24(sp)
 450:	6442                	ld	s0,16(sp)
 452:	64a2                	ld	s1,8(sp)
 454:	6902                	ld	s2,0(sp)
 456:	6105                	add	sp,sp,32
 458:	8082                	ret
    return -1;
 45a:	597d                	li	s2,-1
 45c:	bfc5                	j	44c <stat+0x34>

000000000000045e <atoi>:

int
atoi(const char *s)
{
 45e:	1141                	add	sp,sp,-16
 460:	e422                	sd	s0,8(sp)
 462:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 464:	00054683          	lbu	a3,0(a0)
 468:	fd06879b          	addw	a5,a3,-48
 46c:	0ff7f793          	zext.b	a5,a5
 470:	4625                	li	a2,9
 472:	02f66863          	bltu	a2,a5,4a2 <atoi+0x44>
 476:	872a                	mv	a4,a0
  n = 0;
 478:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 47a:	0705                	add	a4,a4,1
 47c:	0025179b          	sllw	a5,a0,0x2
 480:	9fa9                	addw	a5,a5,a0
 482:	0017979b          	sllw	a5,a5,0x1
 486:	9fb5                	addw	a5,a5,a3
 488:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 48c:	00074683          	lbu	a3,0(a4)
 490:	fd06879b          	addw	a5,a3,-48
 494:	0ff7f793          	zext.b	a5,a5
 498:	fef671e3          	bgeu	a2,a5,47a <atoi+0x1c>
  return n;
}
 49c:	6422                	ld	s0,8(sp)
 49e:	0141                	add	sp,sp,16
 4a0:	8082                	ret
  n = 0;
 4a2:	4501                	li	a0,0
 4a4:	bfe5                	j	49c <atoi+0x3e>

00000000000004a6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4a6:	1141                	add	sp,sp,-16
 4a8:	e422                	sd	s0,8(sp)
 4aa:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4ac:	02b57463          	bgeu	a0,a1,4d4 <memmove+0x2e>
    while(n-- > 0)
 4b0:	00c05f63          	blez	a2,4ce <memmove+0x28>
 4b4:	1602                	sll	a2,a2,0x20
 4b6:	9201                	srl	a2,a2,0x20
 4b8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4bc:	872a                	mv	a4,a0
      *dst++ = *src++;
 4be:	0585                	add	a1,a1,1
 4c0:	0705                	add	a4,a4,1
 4c2:	fff5c683          	lbu	a3,-1(a1)
 4c6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4ca:	fee79ae3          	bne	a5,a4,4be <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4ce:	6422                	ld	s0,8(sp)
 4d0:	0141                	add	sp,sp,16
 4d2:	8082                	ret
    dst += n;
 4d4:	00c50733          	add	a4,a0,a2
    src += n;
 4d8:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4da:	fec05ae3          	blez	a2,4ce <memmove+0x28>
 4de:	fff6079b          	addw	a5,a2,-1
 4e2:	1782                	sll	a5,a5,0x20
 4e4:	9381                	srl	a5,a5,0x20
 4e6:	fff7c793          	not	a5,a5
 4ea:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4ec:	15fd                	add	a1,a1,-1
 4ee:	177d                	add	a4,a4,-1
 4f0:	0005c683          	lbu	a3,0(a1)
 4f4:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4f8:	fee79ae3          	bne	a5,a4,4ec <memmove+0x46>
 4fc:	bfc9                	j	4ce <memmove+0x28>

00000000000004fe <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4fe:	1141                	add	sp,sp,-16
 500:	e422                	sd	s0,8(sp)
 502:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 504:	ca05                	beqz	a2,534 <memcmp+0x36>
 506:	fff6069b          	addw	a3,a2,-1
 50a:	1682                	sll	a3,a3,0x20
 50c:	9281                	srl	a3,a3,0x20
 50e:	0685                	add	a3,a3,1
 510:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 512:	00054783          	lbu	a5,0(a0)
 516:	0005c703          	lbu	a4,0(a1)
 51a:	00e79863          	bne	a5,a4,52a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 51e:	0505                	add	a0,a0,1
    p2++;
 520:	0585                	add	a1,a1,1
  while (n-- > 0) {
 522:	fed518e3          	bne	a0,a3,512 <memcmp+0x14>
  }
  return 0;
 526:	4501                	li	a0,0
 528:	a019                	j	52e <memcmp+0x30>
      return *p1 - *p2;
 52a:	40e7853b          	subw	a0,a5,a4
}
 52e:	6422                	ld	s0,8(sp)
 530:	0141                	add	sp,sp,16
 532:	8082                	ret
  return 0;
 534:	4501                	li	a0,0
 536:	bfe5                	j	52e <memcmp+0x30>

0000000000000538 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 538:	1141                	add	sp,sp,-16
 53a:	e406                	sd	ra,8(sp)
 53c:	e022                	sd	s0,0(sp)
 53e:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 540:	00000097          	auipc	ra,0x0
 544:	f66080e7          	jalr	-154(ra) # 4a6 <memmove>
}
 548:	60a2                	ld	ra,8(sp)
 54a:	6402                	ld	s0,0(sp)
 54c:	0141                	add	sp,sp,16
 54e:	8082                	ret

0000000000000550 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 550:	4885                	li	a7,1
 ecall
 552:	00000073          	ecall
 ret
 556:	8082                	ret

0000000000000558 <exit>:
.global exit
exit:
 li a7, SYS_exit
 558:	4889                	li	a7,2
 ecall
 55a:	00000073          	ecall
 ret
 55e:	8082                	ret

0000000000000560 <wait>:
.global wait
wait:
 li a7, SYS_wait
 560:	488d                	li	a7,3
 ecall
 562:	00000073          	ecall
 ret
 566:	8082                	ret

0000000000000568 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 568:	4891                	li	a7,4
 ecall
 56a:	00000073          	ecall
 ret
 56e:	8082                	ret

0000000000000570 <read>:
.global read
read:
 li a7, SYS_read
 570:	4895                	li	a7,5
 ecall
 572:	00000073          	ecall
 ret
 576:	8082                	ret

0000000000000578 <write>:
.global write
write:
 li a7, SYS_write
 578:	48c1                	li	a7,16
 ecall
 57a:	00000073          	ecall
 ret
 57e:	8082                	ret

0000000000000580 <close>:
.global close
close:
 li a7, SYS_close
 580:	48d5                	li	a7,21
 ecall
 582:	00000073          	ecall
 ret
 586:	8082                	ret

0000000000000588 <kill>:
.global kill
kill:
 li a7, SYS_kill
 588:	4899                	li	a7,6
 ecall
 58a:	00000073          	ecall
 ret
 58e:	8082                	ret

0000000000000590 <exec>:
.global exec
exec:
 li a7, SYS_exec
 590:	489d                	li	a7,7
 ecall
 592:	00000073          	ecall
 ret
 596:	8082                	ret

0000000000000598 <open>:
.global open
open:
 li a7, SYS_open
 598:	48bd                	li	a7,15
 ecall
 59a:	00000073          	ecall
 ret
 59e:	8082                	ret

00000000000005a0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5a0:	48c5                	li	a7,17
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5a8:	48c9                	li	a7,18
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5b0:	48a1                	li	a7,8
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <link>:
.global link
link:
 li a7, SYS_link
 5b8:	48cd                	li	a7,19
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5c0:	48d1                	li	a7,20
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5c8:	48a5                	li	a7,9
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5d0:	48a9                	li	a7,10
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5d8:	48ad                	li	a7,11
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 5e0:	48b1                	li	a7,12
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 5e8:	48b5                	li	a7,13
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5f0:	48b9                	li	a7,14
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 5f8:	48d9                	li	a7,22
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 600:	1101                	add	sp,sp,-32
 602:	ec06                	sd	ra,24(sp)
 604:	e822                	sd	s0,16(sp)
 606:	1000                	add	s0,sp,32
 608:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 60c:	4605                	li	a2,1
 60e:	fef40593          	add	a1,s0,-17
 612:	00000097          	auipc	ra,0x0
 616:	f66080e7          	jalr	-154(ra) # 578 <write>
}
 61a:	60e2                	ld	ra,24(sp)
 61c:	6442                	ld	s0,16(sp)
 61e:	6105                	add	sp,sp,32
 620:	8082                	ret

0000000000000622 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 622:	7139                	add	sp,sp,-64
 624:	fc06                	sd	ra,56(sp)
 626:	f822                	sd	s0,48(sp)
 628:	f426                	sd	s1,40(sp)
 62a:	f04a                	sd	s2,32(sp)
 62c:	ec4e                	sd	s3,24(sp)
 62e:	0080                	add	s0,sp,64
 630:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 632:	c299                	beqz	a3,638 <printint+0x16>
 634:	0805c963          	bltz	a1,6c6 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 638:	2581                	sext.w	a1,a1
  neg = 0;
 63a:	4881                	li	a7,0
 63c:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 640:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 642:	2601                	sext.w	a2,a2
 644:	00000517          	auipc	a0,0x0
 648:	4fc50513          	add	a0,a0,1276 # b40 <digits>
 64c:	883a                	mv	a6,a4
 64e:	2705                	addw	a4,a4,1
 650:	02c5f7bb          	remuw	a5,a1,a2
 654:	1782                	sll	a5,a5,0x20
 656:	9381                	srl	a5,a5,0x20
 658:	97aa                	add	a5,a5,a0
 65a:	0007c783          	lbu	a5,0(a5)
 65e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 662:	0005879b          	sext.w	a5,a1
 666:	02c5d5bb          	divuw	a1,a1,a2
 66a:	0685                	add	a3,a3,1
 66c:	fec7f0e3          	bgeu	a5,a2,64c <printint+0x2a>
  if(neg)
 670:	00088c63          	beqz	a7,688 <printint+0x66>
    buf[i++] = '-';
 674:	fd070793          	add	a5,a4,-48
 678:	00878733          	add	a4,a5,s0
 67c:	02d00793          	li	a5,45
 680:	fef70823          	sb	a5,-16(a4)
 684:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 688:	02e05863          	blez	a4,6b8 <printint+0x96>
 68c:	fc040793          	add	a5,s0,-64
 690:	00e78933          	add	s2,a5,a4
 694:	fff78993          	add	s3,a5,-1
 698:	99ba                	add	s3,s3,a4
 69a:	377d                	addw	a4,a4,-1
 69c:	1702                	sll	a4,a4,0x20
 69e:	9301                	srl	a4,a4,0x20
 6a0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6a4:	fff94583          	lbu	a1,-1(s2)
 6a8:	8526                	mv	a0,s1
 6aa:	00000097          	auipc	ra,0x0
 6ae:	f56080e7          	jalr	-170(ra) # 600 <putc>
  while(--i >= 0)
 6b2:	197d                	add	s2,s2,-1
 6b4:	ff3918e3          	bne	s2,s3,6a4 <printint+0x82>
}
 6b8:	70e2                	ld	ra,56(sp)
 6ba:	7442                	ld	s0,48(sp)
 6bc:	74a2                	ld	s1,40(sp)
 6be:	7902                	ld	s2,32(sp)
 6c0:	69e2                	ld	s3,24(sp)
 6c2:	6121                	add	sp,sp,64
 6c4:	8082                	ret
    x = -xx;
 6c6:	40b005bb          	negw	a1,a1
    neg = 1;
 6ca:	4885                	li	a7,1
    x = -xx;
 6cc:	bf85                	j	63c <printint+0x1a>

00000000000006ce <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6ce:	715d                	add	sp,sp,-80
 6d0:	e486                	sd	ra,72(sp)
 6d2:	e0a2                	sd	s0,64(sp)
 6d4:	fc26                	sd	s1,56(sp)
 6d6:	f84a                	sd	s2,48(sp)
 6d8:	f44e                	sd	s3,40(sp)
 6da:	f052                	sd	s4,32(sp)
 6dc:	ec56                	sd	s5,24(sp)
 6de:	e85a                	sd	s6,16(sp)
 6e0:	e45e                	sd	s7,8(sp)
 6e2:	e062                	sd	s8,0(sp)
 6e4:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6e6:	0005c903          	lbu	s2,0(a1)
 6ea:	18090c63          	beqz	s2,882 <vprintf+0x1b4>
 6ee:	8aaa                	mv	s5,a0
 6f0:	8bb2                	mv	s7,a2
 6f2:	00158493          	add	s1,a1,1
  state = 0;
 6f6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 6f8:	02500a13          	li	s4,37
 6fc:	4b55                	li	s6,21
 6fe:	a839                	j	71c <vprintf+0x4e>
        putc(fd, c);
 700:	85ca                	mv	a1,s2
 702:	8556                	mv	a0,s5
 704:	00000097          	auipc	ra,0x0
 708:	efc080e7          	jalr	-260(ra) # 600 <putc>
 70c:	a019                	j	712 <vprintf+0x44>
    } else if(state == '%'){
 70e:	01498d63          	beq	s3,s4,728 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 712:	0485                	add	s1,s1,1
 714:	fff4c903          	lbu	s2,-1(s1)
 718:	16090563          	beqz	s2,882 <vprintf+0x1b4>
    if(state == 0){
 71c:	fe0999e3          	bnez	s3,70e <vprintf+0x40>
      if(c == '%'){
 720:	ff4910e3          	bne	s2,s4,700 <vprintf+0x32>
        state = '%';
 724:	89d2                	mv	s3,s4
 726:	b7f5                	j	712 <vprintf+0x44>
      if(c == 'd'){
 728:	13490263          	beq	s2,s4,84c <vprintf+0x17e>
 72c:	f9d9079b          	addw	a5,s2,-99
 730:	0ff7f793          	zext.b	a5,a5
 734:	12fb6563          	bltu	s6,a5,85e <vprintf+0x190>
 738:	f9d9079b          	addw	a5,s2,-99
 73c:	0ff7f713          	zext.b	a4,a5
 740:	10eb6f63          	bltu	s6,a4,85e <vprintf+0x190>
 744:	00271793          	sll	a5,a4,0x2
 748:	00000717          	auipc	a4,0x0
 74c:	3a070713          	add	a4,a4,928 # ae8 <malloc+0x168>
 750:	97ba                	add	a5,a5,a4
 752:	439c                	lw	a5,0(a5)
 754:	97ba                	add	a5,a5,a4
 756:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 758:	008b8913          	add	s2,s7,8
 75c:	4685                	li	a3,1
 75e:	4629                	li	a2,10
 760:	000ba583          	lw	a1,0(s7)
 764:	8556                	mv	a0,s5
 766:	00000097          	auipc	ra,0x0
 76a:	ebc080e7          	jalr	-324(ra) # 622 <printint>
 76e:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 770:	4981                	li	s3,0
 772:	b745                	j	712 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 774:	008b8913          	add	s2,s7,8
 778:	4681                	li	a3,0
 77a:	4629                	li	a2,10
 77c:	000ba583          	lw	a1,0(s7)
 780:	8556                	mv	a0,s5
 782:	00000097          	auipc	ra,0x0
 786:	ea0080e7          	jalr	-352(ra) # 622 <printint>
 78a:	8bca                	mv	s7,s2
      state = 0;
 78c:	4981                	li	s3,0
 78e:	b751                	j	712 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 790:	008b8913          	add	s2,s7,8
 794:	4681                	li	a3,0
 796:	4641                	li	a2,16
 798:	000ba583          	lw	a1,0(s7)
 79c:	8556                	mv	a0,s5
 79e:	00000097          	auipc	ra,0x0
 7a2:	e84080e7          	jalr	-380(ra) # 622 <printint>
 7a6:	8bca                	mv	s7,s2
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	b7a5                	j	712 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 7ac:	008b8c13          	add	s8,s7,8
 7b0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7b4:	03000593          	li	a1,48
 7b8:	8556                	mv	a0,s5
 7ba:	00000097          	auipc	ra,0x0
 7be:	e46080e7          	jalr	-442(ra) # 600 <putc>
  putc(fd, 'x');
 7c2:	07800593          	li	a1,120
 7c6:	8556                	mv	a0,s5
 7c8:	00000097          	auipc	ra,0x0
 7cc:	e38080e7          	jalr	-456(ra) # 600 <putc>
 7d0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7d2:	00000b97          	auipc	s7,0x0
 7d6:	36eb8b93          	add	s7,s7,878 # b40 <digits>
 7da:	03c9d793          	srl	a5,s3,0x3c
 7de:	97de                	add	a5,a5,s7
 7e0:	0007c583          	lbu	a1,0(a5)
 7e4:	8556                	mv	a0,s5
 7e6:	00000097          	auipc	ra,0x0
 7ea:	e1a080e7          	jalr	-486(ra) # 600 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7ee:	0992                	sll	s3,s3,0x4
 7f0:	397d                	addw	s2,s2,-1
 7f2:	fe0914e3          	bnez	s2,7da <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 7f6:	8be2                	mv	s7,s8
      state = 0;
 7f8:	4981                	li	s3,0
 7fa:	bf21                	j	712 <vprintf+0x44>
        s = va_arg(ap, char*);
 7fc:	008b8993          	add	s3,s7,8
 800:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 804:	02090163          	beqz	s2,826 <vprintf+0x158>
        while(*s != 0){
 808:	00094583          	lbu	a1,0(s2)
 80c:	c9a5                	beqz	a1,87c <vprintf+0x1ae>
          putc(fd, *s);
 80e:	8556                	mv	a0,s5
 810:	00000097          	auipc	ra,0x0
 814:	df0080e7          	jalr	-528(ra) # 600 <putc>
          s++;
 818:	0905                	add	s2,s2,1
        while(*s != 0){
 81a:	00094583          	lbu	a1,0(s2)
 81e:	f9e5                	bnez	a1,80e <vprintf+0x140>
        s = va_arg(ap, char*);
 820:	8bce                	mv	s7,s3
      state = 0;
 822:	4981                	li	s3,0
 824:	b5fd                	j	712 <vprintf+0x44>
          s = "(null)";
 826:	00000917          	auipc	s2,0x0
 82a:	2ba90913          	add	s2,s2,698 # ae0 <malloc+0x160>
        while(*s != 0){
 82e:	02800593          	li	a1,40
 832:	bff1                	j	80e <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 834:	008b8913          	add	s2,s7,8
 838:	000bc583          	lbu	a1,0(s7)
 83c:	8556                	mv	a0,s5
 83e:	00000097          	auipc	ra,0x0
 842:	dc2080e7          	jalr	-574(ra) # 600 <putc>
 846:	8bca                	mv	s7,s2
      state = 0;
 848:	4981                	li	s3,0
 84a:	b5e1                	j	712 <vprintf+0x44>
        putc(fd, c);
 84c:	02500593          	li	a1,37
 850:	8556                	mv	a0,s5
 852:	00000097          	auipc	ra,0x0
 856:	dae080e7          	jalr	-594(ra) # 600 <putc>
      state = 0;
 85a:	4981                	li	s3,0
 85c:	bd5d                	j	712 <vprintf+0x44>
        putc(fd, '%');
 85e:	02500593          	li	a1,37
 862:	8556                	mv	a0,s5
 864:	00000097          	auipc	ra,0x0
 868:	d9c080e7          	jalr	-612(ra) # 600 <putc>
        putc(fd, c);
 86c:	85ca                	mv	a1,s2
 86e:	8556                	mv	a0,s5
 870:	00000097          	auipc	ra,0x0
 874:	d90080e7          	jalr	-624(ra) # 600 <putc>
      state = 0;
 878:	4981                	li	s3,0
 87a:	bd61                	j	712 <vprintf+0x44>
        s = va_arg(ap, char*);
 87c:	8bce                	mv	s7,s3
      state = 0;
 87e:	4981                	li	s3,0
 880:	bd49                	j	712 <vprintf+0x44>
    }
  }
}
 882:	60a6                	ld	ra,72(sp)
 884:	6406                	ld	s0,64(sp)
 886:	74e2                	ld	s1,56(sp)
 888:	7942                	ld	s2,48(sp)
 88a:	79a2                	ld	s3,40(sp)
 88c:	7a02                	ld	s4,32(sp)
 88e:	6ae2                	ld	s5,24(sp)
 890:	6b42                	ld	s6,16(sp)
 892:	6ba2                	ld	s7,8(sp)
 894:	6c02                	ld	s8,0(sp)
 896:	6161                	add	sp,sp,80
 898:	8082                	ret

000000000000089a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 89a:	715d                	add	sp,sp,-80
 89c:	ec06                	sd	ra,24(sp)
 89e:	e822                	sd	s0,16(sp)
 8a0:	1000                	add	s0,sp,32
 8a2:	e010                	sd	a2,0(s0)
 8a4:	e414                	sd	a3,8(s0)
 8a6:	e818                	sd	a4,16(s0)
 8a8:	ec1c                	sd	a5,24(s0)
 8aa:	03043023          	sd	a6,32(s0)
 8ae:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8b2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8b6:	8622                	mv	a2,s0
 8b8:	00000097          	auipc	ra,0x0
 8bc:	e16080e7          	jalr	-490(ra) # 6ce <vprintf>
}
 8c0:	60e2                	ld	ra,24(sp)
 8c2:	6442                	ld	s0,16(sp)
 8c4:	6161                	add	sp,sp,80
 8c6:	8082                	ret

00000000000008c8 <printf>:

void
printf(const char *fmt, ...)
{
 8c8:	711d                	add	sp,sp,-96
 8ca:	ec06                	sd	ra,24(sp)
 8cc:	e822                	sd	s0,16(sp)
 8ce:	1000                	add	s0,sp,32
 8d0:	e40c                	sd	a1,8(s0)
 8d2:	e810                	sd	a2,16(s0)
 8d4:	ec14                	sd	a3,24(s0)
 8d6:	f018                	sd	a4,32(s0)
 8d8:	f41c                	sd	a5,40(s0)
 8da:	03043823          	sd	a6,48(s0)
 8de:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8e2:	00840613          	add	a2,s0,8
 8e6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8ea:	85aa                	mv	a1,a0
 8ec:	4505                	li	a0,1
 8ee:	00000097          	auipc	ra,0x0
 8f2:	de0080e7          	jalr	-544(ra) # 6ce <vprintf>
}
 8f6:	60e2                	ld	ra,24(sp)
 8f8:	6442                	ld	s0,16(sp)
 8fa:	6125                	add	sp,sp,96
 8fc:	8082                	ret

00000000000008fe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8fe:	1141                	add	sp,sp,-16
 900:	e422                	sd	s0,8(sp)
 902:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 904:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 908:	00000797          	auipc	a5,0x0
 90c:	6f87b783          	ld	a5,1784(a5) # 1000 <freep>
 910:	a02d                	j	93a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 912:	4618                	lw	a4,8(a2)
 914:	9f2d                	addw	a4,a4,a1
 916:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 91a:	6398                	ld	a4,0(a5)
 91c:	6310                	ld	a2,0(a4)
 91e:	a83d                	j	95c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 920:	ff852703          	lw	a4,-8(a0)
 924:	9f31                	addw	a4,a4,a2
 926:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 928:	ff053683          	ld	a3,-16(a0)
 92c:	a091                	j	970 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 92e:	6398                	ld	a4,0(a5)
 930:	00e7e463          	bltu	a5,a4,938 <free+0x3a>
 934:	00e6ea63          	bltu	a3,a4,948 <free+0x4a>
{
 938:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 93a:	fed7fae3          	bgeu	a5,a3,92e <free+0x30>
 93e:	6398                	ld	a4,0(a5)
 940:	00e6e463          	bltu	a3,a4,948 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 944:	fee7eae3          	bltu	a5,a4,938 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 948:	ff852583          	lw	a1,-8(a0)
 94c:	6390                	ld	a2,0(a5)
 94e:	02059813          	sll	a6,a1,0x20
 952:	01c85713          	srl	a4,a6,0x1c
 956:	9736                	add	a4,a4,a3
 958:	fae60de3          	beq	a2,a4,912 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 95c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 960:	4790                	lw	a2,8(a5)
 962:	02061593          	sll	a1,a2,0x20
 966:	01c5d713          	srl	a4,a1,0x1c
 96a:	973e                	add	a4,a4,a5
 96c:	fae68ae3          	beq	a3,a4,920 <free+0x22>
    p->s.ptr = bp->s.ptr;
 970:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 972:	00000717          	auipc	a4,0x0
 976:	68f73723          	sd	a5,1678(a4) # 1000 <freep>
}
 97a:	6422                	ld	s0,8(sp)
 97c:	0141                	add	sp,sp,16
 97e:	8082                	ret

0000000000000980 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 980:	7139                	add	sp,sp,-64
 982:	fc06                	sd	ra,56(sp)
 984:	f822                	sd	s0,48(sp)
 986:	f426                	sd	s1,40(sp)
 988:	f04a                	sd	s2,32(sp)
 98a:	ec4e                	sd	s3,24(sp)
 98c:	e852                	sd	s4,16(sp)
 98e:	e456                	sd	s5,8(sp)
 990:	e05a                	sd	s6,0(sp)
 992:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 994:	02051493          	sll	s1,a0,0x20
 998:	9081                	srl	s1,s1,0x20
 99a:	04bd                	add	s1,s1,15
 99c:	8091                	srl	s1,s1,0x4
 99e:	0014899b          	addw	s3,s1,1
 9a2:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 9a4:	00000517          	auipc	a0,0x0
 9a8:	65c53503          	ld	a0,1628(a0) # 1000 <freep>
 9ac:	c515                	beqz	a0,9d8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9b0:	4798                	lw	a4,8(a5)
 9b2:	02977f63          	bgeu	a4,s1,9f0 <malloc+0x70>
  if(nu < 4096)
 9b6:	8a4e                	mv	s4,s3
 9b8:	0009871b          	sext.w	a4,s3
 9bc:	6685                	lui	a3,0x1
 9be:	00d77363          	bgeu	a4,a3,9c4 <malloc+0x44>
 9c2:	6a05                	lui	s4,0x1
 9c4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9c8:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9cc:	00000917          	auipc	s2,0x0
 9d0:	63490913          	add	s2,s2,1588 # 1000 <freep>
  if(p == (char*)-1)
 9d4:	5afd                	li	s5,-1
 9d6:	a895                	j	a4a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 9d8:	00000797          	auipc	a5,0x0
 9dc:	64878793          	add	a5,a5,1608 # 1020 <base>
 9e0:	00000717          	auipc	a4,0x0
 9e4:	62f73023          	sd	a5,1568(a4) # 1000 <freep>
 9e8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9ea:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9ee:	b7e1                	j	9b6 <malloc+0x36>
      if(p->s.size == nunits)
 9f0:	02e48c63          	beq	s1,a4,a28 <malloc+0xa8>
        p->s.size -= nunits;
 9f4:	4137073b          	subw	a4,a4,s3
 9f8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9fa:	02071693          	sll	a3,a4,0x20
 9fe:	01c6d713          	srl	a4,a3,0x1c
 a02:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a04:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a08:	00000717          	auipc	a4,0x0
 a0c:	5ea73c23          	sd	a0,1528(a4) # 1000 <freep>
      return (void*)(p + 1);
 a10:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a14:	70e2                	ld	ra,56(sp)
 a16:	7442                	ld	s0,48(sp)
 a18:	74a2                	ld	s1,40(sp)
 a1a:	7902                	ld	s2,32(sp)
 a1c:	69e2                	ld	s3,24(sp)
 a1e:	6a42                	ld	s4,16(sp)
 a20:	6aa2                	ld	s5,8(sp)
 a22:	6b02                	ld	s6,0(sp)
 a24:	6121                	add	sp,sp,64
 a26:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a28:	6398                	ld	a4,0(a5)
 a2a:	e118                	sd	a4,0(a0)
 a2c:	bff1                	j	a08 <malloc+0x88>
  hp->s.size = nu;
 a2e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a32:	0541                	add	a0,a0,16
 a34:	00000097          	auipc	ra,0x0
 a38:	eca080e7          	jalr	-310(ra) # 8fe <free>
  return freep;
 a3c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a40:	d971                	beqz	a0,a14 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a42:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a44:	4798                	lw	a4,8(a5)
 a46:	fa9775e3          	bgeu	a4,s1,9f0 <malloc+0x70>
    if(p == freep)
 a4a:	00093703          	ld	a4,0(s2)
 a4e:	853e                	mv	a0,a5
 a50:	fef719e3          	bne	a4,a5,a42 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 a54:	8552                	mv	a0,s4
 a56:	00000097          	auipc	ra,0x0
 a5a:	b8a080e7          	jalr	-1142(ra) # 5e0 <sbrk>
  if(p == (char*)-1)
 a5e:	fd5518e3          	bne	a0,s5,a2e <malloc+0xae>
        return 0;
 a62:	4501                	li	a0,0
 a64:	bf45                	j	a14 <malloc+0x94>
