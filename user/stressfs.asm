
user/_stressfs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

int
main(int argc, char *argv[])
{
   0:	dd010113          	add	sp,sp,-560
   4:	22113423          	sd	ra,552(sp)
   8:	22813023          	sd	s0,544(sp)
   c:	20913c23          	sd	s1,536(sp)
  10:	21213823          	sd	s2,528(sp)
  14:	1c00                	add	s0,sp,560
  int fd, i;
  char path[] = "stressfs0";
  16:	00001797          	auipc	a5,0x1
  1a:	8da78793          	add	a5,a5,-1830 # 8f0 <malloc+0x11e>
  1e:	6398                	ld	a4,0(a5)
  20:	fce43823          	sd	a4,-48(s0)
  24:	0087d783          	lhu	a5,8(a5)
  28:	fcf41c23          	sh	a5,-40(s0)
  char data[512];

  printf("stressfs starting\n");
  2c:	00001517          	auipc	a0,0x1
  30:	89450513          	add	a0,a0,-1900 # 8c0 <malloc+0xee>
  34:	00000097          	auipc	ra,0x0
  38:	6e6080e7          	jalr	1766(ra) # 71a <printf>
  memset(data, 'a', sizeof(data));
  3c:	20000613          	li	a2,512
  40:	06100593          	li	a1,97
  44:	dd040513          	add	a0,s0,-560
  48:	00000097          	auipc	ra,0x0
  4c:	150080e7          	jalr	336(ra) # 198 <memset>

  for(i = 0; i < 4; i++)
  50:	4481                	li	s1,0
  52:	4911                	li	s2,4
    if(fork() > 0)
  54:	00000097          	auipc	ra,0x0
  58:	336080e7          	jalr	822(ra) # 38a <fork>
  5c:	00a04563          	bgtz	a0,66 <main+0x66>
  for(i = 0; i < 4; i++)
  60:	2485                	addw	s1,s1,1
  62:	ff2499e3          	bne	s1,s2,54 <main+0x54>
      break;

  printf("write %d\n", i);
  66:	85a6                	mv	a1,s1
  68:	00001517          	auipc	a0,0x1
  6c:	87050513          	add	a0,a0,-1936 # 8d8 <malloc+0x106>
  70:	00000097          	auipc	ra,0x0
  74:	6aa080e7          	jalr	1706(ra) # 71a <printf>

  path[8] += i;
  78:	fd844783          	lbu	a5,-40(s0)
  7c:	9fa5                	addw	a5,a5,s1
  7e:	fcf40c23          	sb	a5,-40(s0)
  fd = open(path, O_CREATE | O_RDWR);
  82:	20200593          	li	a1,514
  86:	fd040513          	add	a0,s0,-48
  8a:	00000097          	auipc	ra,0x0
  8e:	348080e7          	jalr	840(ra) # 3d2 <open>
  92:	892a                	mv	s2,a0
  94:	44d1                	li	s1,20
  for(i = 0; i < 20; i++)
//    printf(fd, "%d\n", i);
    write(fd, data, sizeof(data));
  96:	20000613          	li	a2,512
  9a:	dd040593          	add	a1,s0,-560
  9e:	854a                	mv	a0,s2
  a0:	00000097          	auipc	ra,0x0
  a4:	312080e7          	jalr	786(ra) # 3b2 <write>
  for(i = 0; i < 20; i++)
  a8:	34fd                	addw	s1,s1,-1
  aa:	f4f5                	bnez	s1,96 <main+0x96>
  close(fd);
  ac:	854a                	mv	a0,s2
  ae:	00000097          	auipc	ra,0x0
  b2:	30c080e7          	jalr	780(ra) # 3ba <close>

  printf("read\n");
  b6:	00001517          	auipc	a0,0x1
  ba:	83250513          	add	a0,a0,-1998 # 8e8 <malloc+0x116>
  be:	00000097          	auipc	ra,0x0
  c2:	65c080e7          	jalr	1628(ra) # 71a <printf>

  fd = open(path, O_RDONLY);
  c6:	4581                	li	a1,0
  c8:	fd040513          	add	a0,s0,-48
  cc:	00000097          	auipc	ra,0x0
  d0:	306080e7          	jalr	774(ra) # 3d2 <open>
  d4:	892a                	mv	s2,a0
  d6:	44d1                	li	s1,20
  for (i = 0; i < 20; i++)
    read(fd, data, sizeof(data));
  d8:	20000613          	li	a2,512
  dc:	dd040593          	add	a1,s0,-560
  e0:	854a                	mv	a0,s2
  e2:	00000097          	auipc	ra,0x0
  e6:	2c8080e7          	jalr	712(ra) # 3aa <read>
  for (i = 0; i < 20; i++)
  ea:	34fd                	addw	s1,s1,-1
  ec:	f4f5                	bnez	s1,d8 <main+0xd8>
  close(fd);
  ee:	854a                	mv	a0,s2
  f0:	00000097          	auipc	ra,0x0
  f4:	2ca080e7          	jalr	714(ra) # 3ba <close>

  wait(0);
  f8:	4501                	li	a0,0
  fa:	00000097          	auipc	ra,0x0
  fe:	2a0080e7          	jalr	672(ra) # 39a <wait>

  exit(0);
 102:	4501                	li	a0,0
 104:	00000097          	auipc	ra,0x0
 108:	28e080e7          	jalr	654(ra) # 392 <exit>

000000000000010c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 10c:	1141                	add	sp,sp,-16
 10e:	e406                	sd	ra,8(sp)
 110:	e022                	sd	s0,0(sp)
 112:	0800                	add	s0,sp,16
  extern int main();
  main();
 114:	00000097          	auipc	ra,0x0
 118:	eec080e7          	jalr	-276(ra) # 0 <main>
  exit(0);
 11c:	4501                	li	a0,0
 11e:	00000097          	auipc	ra,0x0
 122:	274080e7          	jalr	628(ra) # 392 <exit>

0000000000000126 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 126:	1141                	add	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 12c:	87aa                	mv	a5,a0
 12e:	0585                	add	a1,a1,1
 130:	0785                	add	a5,a5,1
 132:	fff5c703          	lbu	a4,-1(a1)
 136:	fee78fa3          	sb	a4,-1(a5)
 13a:	fb75                	bnez	a4,12e <strcpy+0x8>
    ;
  return os;
}
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	add	sp,sp,16
 140:	8082                	ret

0000000000000142 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 142:	1141                	add	sp,sp,-16
 144:	e422                	sd	s0,8(sp)
 146:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 148:	00054783          	lbu	a5,0(a0)
 14c:	cb91                	beqz	a5,160 <strcmp+0x1e>
 14e:	0005c703          	lbu	a4,0(a1)
 152:	00f71763          	bne	a4,a5,160 <strcmp+0x1e>
    p++, q++;
 156:	0505                	add	a0,a0,1
 158:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 15a:	00054783          	lbu	a5,0(a0)
 15e:	fbe5                	bnez	a5,14e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 160:	0005c503          	lbu	a0,0(a1)
}
 164:	40a7853b          	subw	a0,a5,a0
 168:	6422                	ld	s0,8(sp)
 16a:	0141                	add	sp,sp,16
 16c:	8082                	ret

000000000000016e <strlen>:

uint
strlen(const char *s)
{
 16e:	1141                	add	sp,sp,-16
 170:	e422                	sd	s0,8(sp)
 172:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 174:	00054783          	lbu	a5,0(a0)
 178:	cf91                	beqz	a5,194 <strlen+0x26>
 17a:	0505                	add	a0,a0,1
 17c:	87aa                	mv	a5,a0
 17e:	86be                	mv	a3,a5
 180:	0785                	add	a5,a5,1
 182:	fff7c703          	lbu	a4,-1(a5)
 186:	ff65                	bnez	a4,17e <strlen+0x10>
 188:	40a6853b          	subw	a0,a3,a0
 18c:	2505                	addw	a0,a0,1
    ;
  return n;
}
 18e:	6422                	ld	s0,8(sp)
 190:	0141                	add	sp,sp,16
 192:	8082                	ret
  for(n = 0; s[n]; n++)
 194:	4501                	li	a0,0
 196:	bfe5                	j	18e <strlen+0x20>

0000000000000198 <memset>:

void*
memset(void *dst, int c, uint n)
{
 198:	1141                	add	sp,sp,-16
 19a:	e422                	sd	s0,8(sp)
 19c:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 19e:	ca19                	beqz	a2,1b4 <memset+0x1c>
 1a0:	87aa                	mv	a5,a0
 1a2:	1602                	sll	a2,a2,0x20
 1a4:	9201                	srl	a2,a2,0x20
 1a6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1aa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ae:	0785                	add	a5,a5,1
 1b0:	fee79de3          	bne	a5,a4,1aa <memset+0x12>
  }
  return dst;
}
 1b4:	6422                	ld	s0,8(sp)
 1b6:	0141                	add	sp,sp,16
 1b8:	8082                	ret

00000000000001ba <strchr>:

char*
strchr(const char *s, char c)
{
 1ba:	1141                	add	sp,sp,-16
 1bc:	e422                	sd	s0,8(sp)
 1be:	0800                	add	s0,sp,16
  for(; *s; s++)
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	cb99                	beqz	a5,1da <strchr+0x20>
    if(*s == c)
 1c6:	00f58763          	beq	a1,a5,1d4 <strchr+0x1a>
  for(; *s; s++)
 1ca:	0505                	add	a0,a0,1
 1cc:	00054783          	lbu	a5,0(a0)
 1d0:	fbfd                	bnez	a5,1c6 <strchr+0xc>
      return (char*)s;
  return 0;
 1d2:	4501                	li	a0,0
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	add	sp,sp,16
 1d8:	8082                	ret
  return 0;
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strchr+0x1a>

00000000000001de <gets>:

char*
gets(char *buf, int max)
{
 1de:	711d                	add	sp,sp,-96
 1e0:	ec86                	sd	ra,88(sp)
 1e2:	e8a2                	sd	s0,80(sp)
 1e4:	e4a6                	sd	s1,72(sp)
 1e6:	e0ca                	sd	s2,64(sp)
 1e8:	fc4e                	sd	s3,56(sp)
 1ea:	f852                	sd	s4,48(sp)
 1ec:	f456                	sd	s5,40(sp)
 1ee:	f05a                	sd	s6,32(sp)
 1f0:	ec5e                	sd	s7,24(sp)
 1f2:	1080                	add	s0,sp,96
 1f4:	8baa                	mv	s7,a0
 1f6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f8:	892a                	mv	s2,a0
 1fa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1fc:	4aa9                	li	s5,10
 1fe:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 200:	89a6                	mv	s3,s1
 202:	2485                	addw	s1,s1,1
 204:	0344d863          	bge	s1,s4,234 <gets+0x56>
    cc = read(0, &c, 1);
 208:	4605                	li	a2,1
 20a:	faf40593          	add	a1,s0,-81
 20e:	4501                	li	a0,0
 210:	00000097          	auipc	ra,0x0
 214:	19a080e7          	jalr	410(ra) # 3aa <read>
    if(cc < 1)
 218:	00a05e63          	blez	a0,234 <gets+0x56>
    buf[i++] = c;
 21c:	faf44783          	lbu	a5,-81(s0)
 220:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 224:	01578763          	beq	a5,s5,232 <gets+0x54>
 228:	0905                	add	s2,s2,1
 22a:	fd679be3          	bne	a5,s6,200 <gets+0x22>
  for(i=0; i+1 < max; ){
 22e:	89a6                	mv	s3,s1
 230:	a011                	j	234 <gets+0x56>
 232:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 234:	99de                	add	s3,s3,s7
 236:	00098023          	sb	zero,0(s3)
  return buf;
}
 23a:	855e                	mv	a0,s7
 23c:	60e6                	ld	ra,88(sp)
 23e:	6446                	ld	s0,80(sp)
 240:	64a6                	ld	s1,72(sp)
 242:	6906                	ld	s2,64(sp)
 244:	79e2                	ld	s3,56(sp)
 246:	7a42                	ld	s4,48(sp)
 248:	7aa2                	ld	s5,40(sp)
 24a:	7b02                	ld	s6,32(sp)
 24c:	6be2                	ld	s7,24(sp)
 24e:	6125                	add	sp,sp,96
 250:	8082                	ret

0000000000000252 <stat>:

int
stat(const char *n, struct stat *st)
{
 252:	1101                	add	sp,sp,-32
 254:	ec06                	sd	ra,24(sp)
 256:	e822                	sd	s0,16(sp)
 258:	e426                	sd	s1,8(sp)
 25a:	e04a                	sd	s2,0(sp)
 25c:	1000                	add	s0,sp,32
 25e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 260:	4581                	li	a1,0
 262:	00000097          	auipc	ra,0x0
 266:	170080e7          	jalr	368(ra) # 3d2 <open>
  if(fd < 0)
 26a:	02054563          	bltz	a0,294 <stat+0x42>
 26e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 270:	85ca                	mv	a1,s2
 272:	00000097          	auipc	ra,0x0
 276:	178080e7          	jalr	376(ra) # 3ea <fstat>
 27a:	892a                	mv	s2,a0
  close(fd);
 27c:	8526                	mv	a0,s1
 27e:	00000097          	auipc	ra,0x0
 282:	13c080e7          	jalr	316(ra) # 3ba <close>
  return r;
}
 286:	854a                	mv	a0,s2
 288:	60e2                	ld	ra,24(sp)
 28a:	6442                	ld	s0,16(sp)
 28c:	64a2                	ld	s1,8(sp)
 28e:	6902                	ld	s2,0(sp)
 290:	6105                	add	sp,sp,32
 292:	8082                	ret
    return -1;
 294:	597d                	li	s2,-1
 296:	bfc5                	j	286 <stat+0x34>

0000000000000298 <atoi>:

int
atoi(const char *s)
{
 298:	1141                	add	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 29e:	00054683          	lbu	a3,0(a0)
 2a2:	fd06879b          	addw	a5,a3,-48
 2a6:	0ff7f793          	zext.b	a5,a5
 2aa:	4625                	li	a2,9
 2ac:	02f66863          	bltu	a2,a5,2dc <atoi+0x44>
 2b0:	872a                	mv	a4,a0
  n = 0;
 2b2:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2b4:	0705                	add	a4,a4,1
 2b6:	0025179b          	sllw	a5,a0,0x2
 2ba:	9fa9                	addw	a5,a5,a0
 2bc:	0017979b          	sllw	a5,a5,0x1
 2c0:	9fb5                	addw	a5,a5,a3
 2c2:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2c6:	00074683          	lbu	a3,0(a4)
 2ca:	fd06879b          	addw	a5,a3,-48
 2ce:	0ff7f793          	zext.b	a5,a5
 2d2:	fef671e3          	bgeu	a2,a5,2b4 <atoi+0x1c>
  return n;
}
 2d6:	6422                	ld	s0,8(sp)
 2d8:	0141                	add	sp,sp,16
 2da:	8082                	ret
  n = 0;
 2dc:	4501                	li	a0,0
 2de:	bfe5                	j	2d6 <atoi+0x3e>

00000000000002e0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2e0:	1141                	add	sp,sp,-16
 2e2:	e422                	sd	s0,8(sp)
 2e4:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2e6:	02b57463          	bgeu	a0,a1,30e <memmove+0x2e>
    while(n-- > 0)
 2ea:	00c05f63          	blez	a2,308 <memmove+0x28>
 2ee:	1602                	sll	a2,a2,0x20
 2f0:	9201                	srl	a2,a2,0x20
 2f2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2f6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2f8:	0585                	add	a1,a1,1
 2fa:	0705                	add	a4,a4,1
 2fc:	fff5c683          	lbu	a3,-1(a1)
 300:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 304:	fee79ae3          	bne	a5,a4,2f8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	add	sp,sp,16
 30c:	8082                	ret
    dst += n;
 30e:	00c50733          	add	a4,a0,a2
    src += n;
 312:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 314:	fec05ae3          	blez	a2,308 <memmove+0x28>
 318:	fff6079b          	addw	a5,a2,-1
 31c:	1782                	sll	a5,a5,0x20
 31e:	9381                	srl	a5,a5,0x20
 320:	fff7c793          	not	a5,a5
 324:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 326:	15fd                	add	a1,a1,-1
 328:	177d                	add	a4,a4,-1
 32a:	0005c683          	lbu	a3,0(a1)
 32e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 332:	fee79ae3          	bne	a5,a4,326 <memmove+0x46>
 336:	bfc9                	j	308 <memmove+0x28>

0000000000000338 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 338:	1141                	add	sp,sp,-16
 33a:	e422                	sd	s0,8(sp)
 33c:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 33e:	ca05                	beqz	a2,36e <memcmp+0x36>
 340:	fff6069b          	addw	a3,a2,-1
 344:	1682                	sll	a3,a3,0x20
 346:	9281                	srl	a3,a3,0x20
 348:	0685                	add	a3,a3,1
 34a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 34c:	00054783          	lbu	a5,0(a0)
 350:	0005c703          	lbu	a4,0(a1)
 354:	00e79863          	bne	a5,a4,364 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 358:	0505                	add	a0,a0,1
    p2++;
 35a:	0585                	add	a1,a1,1
  while (n-- > 0) {
 35c:	fed518e3          	bne	a0,a3,34c <memcmp+0x14>
  }
  return 0;
 360:	4501                	li	a0,0
 362:	a019                	j	368 <memcmp+0x30>
      return *p1 - *p2;
 364:	40e7853b          	subw	a0,a5,a4
}
 368:	6422                	ld	s0,8(sp)
 36a:	0141                	add	sp,sp,16
 36c:	8082                	ret
  return 0;
 36e:	4501                	li	a0,0
 370:	bfe5                	j	368 <memcmp+0x30>

0000000000000372 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 372:	1141                	add	sp,sp,-16
 374:	e406                	sd	ra,8(sp)
 376:	e022                	sd	s0,0(sp)
 378:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 37a:	00000097          	auipc	ra,0x0
 37e:	f66080e7          	jalr	-154(ra) # 2e0 <memmove>
}
 382:	60a2                	ld	ra,8(sp)
 384:	6402                	ld	s0,0(sp)
 386:	0141                	add	sp,sp,16
 388:	8082                	ret

000000000000038a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 38a:	4885                	li	a7,1
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <exit>:
.global exit
exit:
 li a7, SYS_exit
 392:	4889                	li	a7,2
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <wait>:
.global wait
wait:
 li a7, SYS_wait
 39a:	488d                	li	a7,3
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a2:	4891                	li	a7,4
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <read>:
.global read
read:
 li a7, SYS_read
 3aa:	4895                	li	a7,5
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <write>:
.global write
write:
 li a7, SYS_write
 3b2:	48c1                	li	a7,16
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <close>:
.global close
close:
 li a7, SYS_close
 3ba:	48d5                	li	a7,21
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c2:	4899                	li	a7,6
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ca:	489d                	li	a7,7
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <open>:
.global open
open:
 li a7, SYS_open
 3d2:	48bd                	li	a7,15
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3da:	48c5                	li	a7,17
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e2:	48c9                	li	a7,18
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ea:	48a1                	li	a7,8
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <link>:
.global link
link:
 li a7, SYS_link
 3f2:	48cd                	li	a7,19
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3fa:	48d1                	li	a7,20
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 402:	48a5                	li	a7,9
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <dup>:
.global dup
dup:
 li a7, SYS_dup
 40a:	48a9                	li	a7,10
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 412:	48ad                	li	a7,11
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 41a:	48b1                	li	a7,12
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 422:	48b5                	li	a7,13
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 42a:	48b9                	li	a7,14
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 432:	48d9                	li	a7,22
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <getreadcount>:
.global getreadcount
getreadcount:
 li a7, SYS_getreadcount
 43a:	48dd                	li	a7,23
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <sigalarm>:
.global sigalarm
sigalarm:
 li a7, SYS_sigalarm
 442:	48e1                	li	a7,24
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <sigreturn>:
.global sigreturn
sigreturn:
 li a7, SYS_sigreturn
 44a:	48e5                	li	a7,25
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 452:	1101                	add	sp,sp,-32
 454:	ec06                	sd	ra,24(sp)
 456:	e822                	sd	s0,16(sp)
 458:	1000                	add	s0,sp,32
 45a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 45e:	4605                	li	a2,1
 460:	fef40593          	add	a1,s0,-17
 464:	00000097          	auipc	ra,0x0
 468:	f4e080e7          	jalr	-178(ra) # 3b2 <write>
}
 46c:	60e2                	ld	ra,24(sp)
 46e:	6442                	ld	s0,16(sp)
 470:	6105                	add	sp,sp,32
 472:	8082                	ret

0000000000000474 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 474:	7139                	add	sp,sp,-64
 476:	fc06                	sd	ra,56(sp)
 478:	f822                	sd	s0,48(sp)
 47a:	f426                	sd	s1,40(sp)
 47c:	f04a                	sd	s2,32(sp)
 47e:	ec4e                	sd	s3,24(sp)
 480:	0080                	add	s0,sp,64
 482:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 484:	c299                	beqz	a3,48a <printint+0x16>
 486:	0805c963          	bltz	a1,518 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 48a:	2581                	sext.w	a1,a1
  neg = 0;
 48c:	4881                	li	a7,0
 48e:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 492:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 494:	2601                	sext.w	a2,a2
 496:	00000517          	auipc	a0,0x0
 49a:	4ca50513          	add	a0,a0,1226 # 960 <digits>
 49e:	883a                	mv	a6,a4
 4a0:	2705                	addw	a4,a4,1
 4a2:	02c5f7bb          	remuw	a5,a1,a2
 4a6:	1782                	sll	a5,a5,0x20
 4a8:	9381                	srl	a5,a5,0x20
 4aa:	97aa                	add	a5,a5,a0
 4ac:	0007c783          	lbu	a5,0(a5)
 4b0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4b4:	0005879b          	sext.w	a5,a1
 4b8:	02c5d5bb          	divuw	a1,a1,a2
 4bc:	0685                	add	a3,a3,1
 4be:	fec7f0e3          	bgeu	a5,a2,49e <printint+0x2a>
  if(neg)
 4c2:	00088c63          	beqz	a7,4da <printint+0x66>
    buf[i++] = '-';
 4c6:	fd070793          	add	a5,a4,-48
 4ca:	00878733          	add	a4,a5,s0
 4ce:	02d00793          	li	a5,45
 4d2:	fef70823          	sb	a5,-16(a4)
 4d6:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 4da:	02e05863          	blez	a4,50a <printint+0x96>
 4de:	fc040793          	add	a5,s0,-64
 4e2:	00e78933          	add	s2,a5,a4
 4e6:	fff78993          	add	s3,a5,-1
 4ea:	99ba                	add	s3,s3,a4
 4ec:	377d                	addw	a4,a4,-1
 4ee:	1702                	sll	a4,a4,0x20
 4f0:	9301                	srl	a4,a4,0x20
 4f2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4f6:	fff94583          	lbu	a1,-1(s2)
 4fa:	8526                	mv	a0,s1
 4fc:	00000097          	auipc	ra,0x0
 500:	f56080e7          	jalr	-170(ra) # 452 <putc>
  while(--i >= 0)
 504:	197d                	add	s2,s2,-1
 506:	ff3918e3          	bne	s2,s3,4f6 <printint+0x82>
}
 50a:	70e2                	ld	ra,56(sp)
 50c:	7442                	ld	s0,48(sp)
 50e:	74a2                	ld	s1,40(sp)
 510:	7902                	ld	s2,32(sp)
 512:	69e2                	ld	s3,24(sp)
 514:	6121                	add	sp,sp,64
 516:	8082                	ret
    x = -xx;
 518:	40b005bb          	negw	a1,a1
    neg = 1;
 51c:	4885                	li	a7,1
    x = -xx;
 51e:	bf85                	j	48e <printint+0x1a>

0000000000000520 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 520:	715d                	add	sp,sp,-80
 522:	e486                	sd	ra,72(sp)
 524:	e0a2                	sd	s0,64(sp)
 526:	fc26                	sd	s1,56(sp)
 528:	f84a                	sd	s2,48(sp)
 52a:	f44e                	sd	s3,40(sp)
 52c:	f052                	sd	s4,32(sp)
 52e:	ec56                	sd	s5,24(sp)
 530:	e85a                	sd	s6,16(sp)
 532:	e45e                	sd	s7,8(sp)
 534:	e062                	sd	s8,0(sp)
 536:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 538:	0005c903          	lbu	s2,0(a1)
 53c:	18090c63          	beqz	s2,6d4 <vprintf+0x1b4>
 540:	8aaa                	mv	s5,a0
 542:	8bb2                	mv	s7,a2
 544:	00158493          	add	s1,a1,1
  state = 0;
 548:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 54a:	02500a13          	li	s4,37
 54e:	4b55                	li	s6,21
 550:	a839                	j	56e <vprintf+0x4e>
        putc(fd, c);
 552:	85ca                	mv	a1,s2
 554:	8556                	mv	a0,s5
 556:	00000097          	auipc	ra,0x0
 55a:	efc080e7          	jalr	-260(ra) # 452 <putc>
 55e:	a019                	j	564 <vprintf+0x44>
    } else if(state == '%'){
 560:	01498d63          	beq	s3,s4,57a <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 564:	0485                	add	s1,s1,1
 566:	fff4c903          	lbu	s2,-1(s1)
 56a:	16090563          	beqz	s2,6d4 <vprintf+0x1b4>
    if(state == 0){
 56e:	fe0999e3          	bnez	s3,560 <vprintf+0x40>
      if(c == '%'){
 572:	ff4910e3          	bne	s2,s4,552 <vprintf+0x32>
        state = '%';
 576:	89d2                	mv	s3,s4
 578:	b7f5                	j	564 <vprintf+0x44>
      if(c == 'd'){
 57a:	13490263          	beq	s2,s4,69e <vprintf+0x17e>
 57e:	f9d9079b          	addw	a5,s2,-99
 582:	0ff7f793          	zext.b	a5,a5
 586:	12fb6563          	bltu	s6,a5,6b0 <vprintf+0x190>
 58a:	f9d9079b          	addw	a5,s2,-99
 58e:	0ff7f713          	zext.b	a4,a5
 592:	10eb6f63          	bltu	s6,a4,6b0 <vprintf+0x190>
 596:	00271793          	sll	a5,a4,0x2
 59a:	00000717          	auipc	a4,0x0
 59e:	36e70713          	add	a4,a4,878 # 908 <malloc+0x136>
 5a2:	97ba                	add	a5,a5,a4
 5a4:	439c                	lw	a5,0(a5)
 5a6:	97ba                	add	a5,a5,a4
 5a8:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5aa:	008b8913          	add	s2,s7,8
 5ae:	4685                	li	a3,1
 5b0:	4629                	li	a2,10
 5b2:	000ba583          	lw	a1,0(s7)
 5b6:	8556                	mv	a0,s5
 5b8:	00000097          	auipc	ra,0x0
 5bc:	ebc080e7          	jalr	-324(ra) # 474 <printint>
 5c0:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5c2:	4981                	li	s3,0
 5c4:	b745                	j	564 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c6:	008b8913          	add	s2,s7,8
 5ca:	4681                	li	a3,0
 5cc:	4629                	li	a2,10
 5ce:	000ba583          	lw	a1,0(s7)
 5d2:	8556                	mv	a0,s5
 5d4:	00000097          	auipc	ra,0x0
 5d8:	ea0080e7          	jalr	-352(ra) # 474 <printint>
 5dc:	8bca                	mv	s7,s2
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	b751                	j	564 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 5e2:	008b8913          	add	s2,s7,8
 5e6:	4681                	li	a3,0
 5e8:	4641                	li	a2,16
 5ea:	000ba583          	lw	a1,0(s7)
 5ee:	8556                	mv	a0,s5
 5f0:	00000097          	auipc	ra,0x0
 5f4:	e84080e7          	jalr	-380(ra) # 474 <printint>
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	b7a5                	j	564 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5fe:	008b8c13          	add	s8,s7,8
 602:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 606:	03000593          	li	a1,48
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	e46080e7          	jalr	-442(ra) # 452 <putc>
  putc(fd, 'x');
 614:	07800593          	li	a1,120
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	e38080e7          	jalr	-456(ra) # 452 <putc>
 622:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 624:	00000b97          	auipc	s7,0x0
 628:	33cb8b93          	add	s7,s7,828 # 960 <digits>
 62c:	03c9d793          	srl	a5,s3,0x3c
 630:	97de                	add	a5,a5,s7
 632:	0007c583          	lbu	a1,0(a5)
 636:	8556                	mv	a0,s5
 638:	00000097          	auipc	ra,0x0
 63c:	e1a080e7          	jalr	-486(ra) # 452 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 640:	0992                	sll	s3,s3,0x4
 642:	397d                	addw	s2,s2,-1
 644:	fe0914e3          	bnez	s2,62c <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 648:	8be2                	mv	s7,s8
      state = 0;
 64a:	4981                	li	s3,0
 64c:	bf21                	j	564 <vprintf+0x44>
        s = va_arg(ap, char*);
 64e:	008b8993          	add	s3,s7,8
 652:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 656:	02090163          	beqz	s2,678 <vprintf+0x158>
        while(*s != 0){
 65a:	00094583          	lbu	a1,0(s2)
 65e:	c9a5                	beqz	a1,6ce <vprintf+0x1ae>
          putc(fd, *s);
 660:	8556                	mv	a0,s5
 662:	00000097          	auipc	ra,0x0
 666:	df0080e7          	jalr	-528(ra) # 452 <putc>
          s++;
 66a:	0905                	add	s2,s2,1
        while(*s != 0){
 66c:	00094583          	lbu	a1,0(s2)
 670:	f9e5                	bnez	a1,660 <vprintf+0x140>
        s = va_arg(ap, char*);
 672:	8bce                	mv	s7,s3
      state = 0;
 674:	4981                	li	s3,0
 676:	b5fd                	j	564 <vprintf+0x44>
          s = "(null)";
 678:	00000917          	auipc	s2,0x0
 67c:	28890913          	add	s2,s2,648 # 900 <malloc+0x12e>
        while(*s != 0){
 680:	02800593          	li	a1,40
 684:	bff1                	j	660 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 686:	008b8913          	add	s2,s7,8
 68a:	000bc583          	lbu	a1,0(s7)
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	dc2080e7          	jalr	-574(ra) # 452 <putc>
 698:	8bca                	mv	s7,s2
      state = 0;
 69a:	4981                	li	s3,0
 69c:	b5e1                	j	564 <vprintf+0x44>
        putc(fd, c);
 69e:	02500593          	li	a1,37
 6a2:	8556                	mv	a0,s5
 6a4:	00000097          	auipc	ra,0x0
 6a8:	dae080e7          	jalr	-594(ra) # 452 <putc>
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	bd5d                	j	564 <vprintf+0x44>
        putc(fd, '%');
 6b0:	02500593          	li	a1,37
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	d9c080e7          	jalr	-612(ra) # 452 <putc>
        putc(fd, c);
 6be:	85ca                	mv	a1,s2
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	d90080e7          	jalr	-624(ra) # 452 <putc>
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	bd61                	j	564 <vprintf+0x44>
        s = va_arg(ap, char*);
 6ce:	8bce                	mv	s7,s3
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	bd49                	j	564 <vprintf+0x44>
    }
  }
}
 6d4:	60a6                	ld	ra,72(sp)
 6d6:	6406                	ld	s0,64(sp)
 6d8:	74e2                	ld	s1,56(sp)
 6da:	7942                	ld	s2,48(sp)
 6dc:	79a2                	ld	s3,40(sp)
 6de:	7a02                	ld	s4,32(sp)
 6e0:	6ae2                	ld	s5,24(sp)
 6e2:	6b42                	ld	s6,16(sp)
 6e4:	6ba2                	ld	s7,8(sp)
 6e6:	6c02                	ld	s8,0(sp)
 6e8:	6161                	add	sp,sp,80
 6ea:	8082                	ret

00000000000006ec <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ec:	715d                	add	sp,sp,-80
 6ee:	ec06                	sd	ra,24(sp)
 6f0:	e822                	sd	s0,16(sp)
 6f2:	1000                	add	s0,sp,32
 6f4:	e010                	sd	a2,0(s0)
 6f6:	e414                	sd	a3,8(s0)
 6f8:	e818                	sd	a4,16(s0)
 6fa:	ec1c                	sd	a5,24(s0)
 6fc:	03043023          	sd	a6,32(s0)
 700:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 704:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 708:	8622                	mv	a2,s0
 70a:	00000097          	auipc	ra,0x0
 70e:	e16080e7          	jalr	-490(ra) # 520 <vprintf>
}
 712:	60e2                	ld	ra,24(sp)
 714:	6442                	ld	s0,16(sp)
 716:	6161                	add	sp,sp,80
 718:	8082                	ret

000000000000071a <printf>:

void
printf(const char *fmt, ...)
{
 71a:	711d                	add	sp,sp,-96
 71c:	ec06                	sd	ra,24(sp)
 71e:	e822                	sd	s0,16(sp)
 720:	1000                	add	s0,sp,32
 722:	e40c                	sd	a1,8(s0)
 724:	e810                	sd	a2,16(s0)
 726:	ec14                	sd	a3,24(s0)
 728:	f018                	sd	a4,32(s0)
 72a:	f41c                	sd	a5,40(s0)
 72c:	03043823          	sd	a6,48(s0)
 730:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 734:	00840613          	add	a2,s0,8
 738:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 73c:	85aa                	mv	a1,a0
 73e:	4505                	li	a0,1
 740:	00000097          	auipc	ra,0x0
 744:	de0080e7          	jalr	-544(ra) # 520 <vprintf>
}
 748:	60e2                	ld	ra,24(sp)
 74a:	6442                	ld	s0,16(sp)
 74c:	6125                	add	sp,sp,96
 74e:	8082                	ret

0000000000000750 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 750:	1141                	add	sp,sp,-16
 752:	e422                	sd	s0,8(sp)
 754:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 756:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 75a:	00001797          	auipc	a5,0x1
 75e:	8a67b783          	ld	a5,-1882(a5) # 1000 <freep>
 762:	a02d                	j	78c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 764:	4618                	lw	a4,8(a2)
 766:	9f2d                	addw	a4,a4,a1
 768:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 76c:	6398                	ld	a4,0(a5)
 76e:	6310                	ld	a2,0(a4)
 770:	a83d                	j	7ae <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 772:	ff852703          	lw	a4,-8(a0)
 776:	9f31                	addw	a4,a4,a2
 778:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 77a:	ff053683          	ld	a3,-16(a0)
 77e:	a091                	j	7c2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 780:	6398                	ld	a4,0(a5)
 782:	00e7e463          	bltu	a5,a4,78a <free+0x3a>
 786:	00e6ea63          	bltu	a3,a4,79a <free+0x4a>
{
 78a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 78c:	fed7fae3          	bgeu	a5,a3,780 <free+0x30>
 790:	6398                	ld	a4,0(a5)
 792:	00e6e463          	bltu	a3,a4,79a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 796:	fee7eae3          	bltu	a5,a4,78a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 79a:	ff852583          	lw	a1,-8(a0)
 79e:	6390                	ld	a2,0(a5)
 7a0:	02059813          	sll	a6,a1,0x20
 7a4:	01c85713          	srl	a4,a6,0x1c
 7a8:	9736                	add	a4,a4,a3
 7aa:	fae60de3          	beq	a2,a4,764 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7ae:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7b2:	4790                	lw	a2,8(a5)
 7b4:	02061593          	sll	a1,a2,0x20
 7b8:	01c5d713          	srl	a4,a1,0x1c
 7bc:	973e                	add	a4,a4,a5
 7be:	fae68ae3          	beq	a3,a4,772 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7c2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7c4:	00001717          	auipc	a4,0x1
 7c8:	82f73e23          	sd	a5,-1988(a4) # 1000 <freep>
}
 7cc:	6422                	ld	s0,8(sp)
 7ce:	0141                	add	sp,sp,16
 7d0:	8082                	ret

00000000000007d2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7d2:	7139                	add	sp,sp,-64
 7d4:	fc06                	sd	ra,56(sp)
 7d6:	f822                	sd	s0,48(sp)
 7d8:	f426                	sd	s1,40(sp)
 7da:	f04a                	sd	s2,32(sp)
 7dc:	ec4e                	sd	s3,24(sp)
 7de:	e852                	sd	s4,16(sp)
 7e0:	e456                	sd	s5,8(sp)
 7e2:	e05a                	sd	s6,0(sp)
 7e4:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e6:	02051493          	sll	s1,a0,0x20
 7ea:	9081                	srl	s1,s1,0x20
 7ec:	04bd                	add	s1,s1,15
 7ee:	8091                	srl	s1,s1,0x4
 7f0:	0014899b          	addw	s3,s1,1
 7f4:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 7f6:	00001517          	auipc	a0,0x1
 7fa:	80a53503          	ld	a0,-2038(a0) # 1000 <freep>
 7fe:	c515                	beqz	a0,82a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 800:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 802:	4798                	lw	a4,8(a5)
 804:	02977f63          	bgeu	a4,s1,842 <malloc+0x70>
  if(nu < 4096)
 808:	8a4e                	mv	s4,s3
 80a:	0009871b          	sext.w	a4,s3
 80e:	6685                	lui	a3,0x1
 810:	00d77363          	bgeu	a4,a3,816 <malloc+0x44>
 814:	6a05                	lui	s4,0x1
 816:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 81a:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 81e:	00000917          	auipc	s2,0x0
 822:	7e290913          	add	s2,s2,2018 # 1000 <freep>
  if(p == (char*)-1)
 826:	5afd                	li	s5,-1
 828:	a895                	j	89c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 82a:	00000797          	auipc	a5,0x0
 82e:	7e678793          	add	a5,a5,2022 # 1010 <base>
 832:	00000717          	auipc	a4,0x0
 836:	7cf73723          	sd	a5,1998(a4) # 1000 <freep>
 83a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 83c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 840:	b7e1                	j	808 <malloc+0x36>
      if(p->s.size == nunits)
 842:	02e48c63          	beq	s1,a4,87a <malloc+0xa8>
        p->s.size -= nunits;
 846:	4137073b          	subw	a4,a4,s3
 84a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 84c:	02071693          	sll	a3,a4,0x20
 850:	01c6d713          	srl	a4,a3,0x1c
 854:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 856:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 85a:	00000717          	auipc	a4,0x0
 85e:	7aa73323          	sd	a0,1958(a4) # 1000 <freep>
      return (void*)(p + 1);
 862:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 866:	70e2                	ld	ra,56(sp)
 868:	7442                	ld	s0,48(sp)
 86a:	74a2                	ld	s1,40(sp)
 86c:	7902                	ld	s2,32(sp)
 86e:	69e2                	ld	s3,24(sp)
 870:	6a42                	ld	s4,16(sp)
 872:	6aa2                	ld	s5,8(sp)
 874:	6b02                	ld	s6,0(sp)
 876:	6121                	add	sp,sp,64
 878:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 87a:	6398                	ld	a4,0(a5)
 87c:	e118                	sd	a4,0(a0)
 87e:	bff1                	j	85a <malloc+0x88>
  hp->s.size = nu;
 880:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 884:	0541                	add	a0,a0,16
 886:	00000097          	auipc	ra,0x0
 88a:	eca080e7          	jalr	-310(ra) # 750 <free>
  return freep;
 88e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 892:	d971                	beqz	a0,866 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 894:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 896:	4798                	lw	a4,8(a5)
 898:	fa9775e3          	bgeu	a4,s1,842 <malloc+0x70>
    if(p == freep)
 89c:	00093703          	ld	a4,0(s2)
 8a0:	853e                	mv	a0,a5
 8a2:	fef719e3          	bne	a4,a5,894 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8a6:	8552                	mv	a0,s4
 8a8:	00000097          	auipc	ra,0x0
 8ac:	b72080e7          	jalr	-1166(ra) # 41a <sbrk>
  if(p == (char*)-1)
 8b0:	fd5518e3          	bne	a0,s5,880 <malloc+0xae>
        return 0;
 8b4:	4501                	li	a0,0
 8b6:	bf45                	j	866 <malloc+0x94>
