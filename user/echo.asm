
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7139                	add	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	add	s0,sp,64
  int i;

  for(i = 1; i < argc; i++){
  12:	4785                	li	a5,1
  14:	06a7d863          	bge	a5,a0,84 <main+0x84>
  18:	00858493          	add	s1,a1,8
  1c:	3579                	addw	a0,a0,-2
  1e:	02051793          	sll	a5,a0,0x20
  22:	01d7d513          	srl	a0,a5,0x1d
  26:	00a48a33          	add	s4,s1,a0
  2a:	05c1                	add	a1,a1,16
  2c:	00a589b3          	add	s3,a1,a0
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  30:	00001a97          	auipc	s5,0x1
  34:	800a8a93          	add	s5,s5,-2048 # 830 <malloc+0xf4>
  38:	a819                	j	4e <main+0x4e>
  3a:	4605                	li	a2,1
  3c:	85d6                	mv	a1,s5
  3e:	4505                	li	a0,1
  40:	00000097          	auipc	ra,0x0
  44:	2f4080e7          	jalr	756(ra) # 334 <write>
  for(i = 1; i < argc; i++){
  48:	04a1                	add	s1,s1,8
  4a:	03348d63          	beq	s1,s3,84 <main+0x84>
    write(1, argv[i], strlen(argv[i]));
  4e:	0004b903          	ld	s2,0(s1)
  52:	854a                	mv	a0,s2
  54:	00000097          	auipc	ra,0x0
  58:	09c080e7          	jalr	156(ra) # f0 <strlen>
  5c:	0005061b          	sext.w	a2,a0
  60:	85ca                	mv	a1,s2
  62:	4505                	li	a0,1
  64:	00000097          	auipc	ra,0x0
  68:	2d0080e7          	jalr	720(ra) # 334 <write>
    if(i + 1 < argc){
  6c:	fd4497e3          	bne	s1,s4,3a <main+0x3a>
    } else {
      write(1, "\n", 1);
  70:	4605                	li	a2,1
  72:	00000597          	auipc	a1,0x0
  76:	7c658593          	add	a1,a1,1990 # 838 <malloc+0xfc>
  7a:	4505                	li	a0,1
  7c:	00000097          	auipc	ra,0x0
  80:	2b8080e7          	jalr	696(ra) # 334 <write>
    }
  }
  exit(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	28e080e7          	jalr	654(ra) # 314 <exit>

000000000000008e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  8e:	1141                	add	sp,sp,-16
  90:	e406                	sd	ra,8(sp)
  92:	e022                	sd	s0,0(sp)
  94:	0800                	add	s0,sp,16
  extern int main();
  main();
  96:	00000097          	auipc	ra,0x0
  9a:	f6a080e7          	jalr	-150(ra) # 0 <main>
  exit(0);
  9e:	4501                	li	a0,0
  a0:	00000097          	auipc	ra,0x0
  a4:	274080e7          	jalr	628(ra) # 314 <exit>

00000000000000a8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  a8:	1141                	add	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ae:	87aa                	mv	a5,a0
  b0:	0585                	add	a1,a1,1
  b2:	0785                	add	a5,a5,1
  b4:	fff5c703          	lbu	a4,-1(a1)
  b8:	fee78fa3          	sb	a4,-1(a5)
  bc:	fb75                	bnez	a4,b0 <strcpy+0x8>
    ;
  return os;
}
  be:	6422                	ld	s0,8(sp)
  c0:	0141                	add	sp,sp,16
  c2:	8082                	ret

00000000000000c4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c4:	1141                	add	sp,sp,-16
  c6:	e422                	sd	s0,8(sp)
  c8:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  ca:	00054783          	lbu	a5,0(a0)
  ce:	cb91                	beqz	a5,e2 <strcmp+0x1e>
  d0:	0005c703          	lbu	a4,0(a1)
  d4:	00f71763          	bne	a4,a5,e2 <strcmp+0x1e>
    p++, q++;
  d8:	0505                	add	a0,a0,1
  da:	0585                	add	a1,a1,1
  while(*p && *p == *q)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	fbe5                	bnez	a5,d0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  e2:	0005c503          	lbu	a0,0(a1)
}
  e6:	40a7853b          	subw	a0,a5,a0
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	add	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strlen>:

uint
strlen(const char *s)
{
  f0:	1141                	add	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cf91                	beqz	a5,116 <strlen+0x26>
  fc:	0505                	add	a0,a0,1
  fe:	87aa                	mv	a5,a0
 100:	86be                	mv	a3,a5
 102:	0785                	add	a5,a5,1
 104:	fff7c703          	lbu	a4,-1(a5)
 108:	ff65                	bnez	a4,100 <strlen+0x10>
 10a:	40a6853b          	subw	a0,a3,a0
 10e:	2505                	addw	a0,a0,1
    ;
  return n;
}
 110:	6422                	ld	s0,8(sp)
 112:	0141                	add	sp,sp,16
 114:	8082                	ret
  for(n = 0; s[n]; n++)
 116:	4501                	li	a0,0
 118:	bfe5                	j	110 <strlen+0x20>

000000000000011a <memset>:

void*
memset(void *dst, int c, uint n)
{
 11a:	1141                	add	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 120:	ca19                	beqz	a2,136 <memset+0x1c>
 122:	87aa                	mv	a5,a0
 124:	1602                	sll	a2,a2,0x20
 126:	9201                	srl	a2,a2,0x20
 128:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 12c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 130:	0785                	add	a5,a5,1
 132:	fee79de3          	bne	a5,a4,12c <memset+0x12>
  }
  return dst;
}
 136:	6422                	ld	s0,8(sp)
 138:	0141                	add	sp,sp,16
 13a:	8082                	ret

000000000000013c <strchr>:

char*
strchr(const char *s, char c)
{
 13c:	1141                	add	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	add	s0,sp,16
  for(; *s; s++)
 142:	00054783          	lbu	a5,0(a0)
 146:	cb99                	beqz	a5,15c <strchr+0x20>
    if(*s == c)
 148:	00f58763          	beq	a1,a5,156 <strchr+0x1a>
  for(; *s; s++)
 14c:	0505                	add	a0,a0,1
 14e:	00054783          	lbu	a5,0(a0)
 152:	fbfd                	bnez	a5,148 <strchr+0xc>
      return (char*)s;
  return 0;
 154:	4501                	li	a0,0
}
 156:	6422                	ld	s0,8(sp)
 158:	0141                	add	sp,sp,16
 15a:	8082                	ret
  return 0;
 15c:	4501                	li	a0,0
 15e:	bfe5                	j	156 <strchr+0x1a>

0000000000000160 <gets>:

char*
gets(char *buf, int max)
{
 160:	711d                	add	sp,sp,-96
 162:	ec86                	sd	ra,88(sp)
 164:	e8a2                	sd	s0,80(sp)
 166:	e4a6                	sd	s1,72(sp)
 168:	e0ca                	sd	s2,64(sp)
 16a:	fc4e                	sd	s3,56(sp)
 16c:	f852                	sd	s4,48(sp)
 16e:	f456                	sd	s5,40(sp)
 170:	f05a                	sd	s6,32(sp)
 172:	ec5e                	sd	s7,24(sp)
 174:	1080                	add	s0,sp,96
 176:	8baa                	mv	s7,a0
 178:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17a:	892a                	mv	s2,a0
 17c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 17e:	4aa9                	li	s5,10
 180:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 182:	89a6                	mv	s3,s1
 184:	2485                	addw	s1,s1,1
 186:	0344d863          	bge	s1,s4,1b6 <gets+0x56>
    cc = read(0, &c, 1);
 18a:	4605                	li	a2,1
 18c:	faf40593          	add	a1,s0,-81
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	19a080e7          	jalr	410(ra) # 32c <read>
    if(cc < 1)
 19a:	00a05e63          	blez	a0,1b6 <gets+0x56>
    buf[i++] = c;
 19e:	faf44783          	lbu	a5,-81(s0)
 1a2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1a6:	01578763          	beq	a5,s5,1b4 <gets+0x54>
 1aa:	0905                	add	s2,s2,1
 1ac:	fd679be3          	bne	a5,s6,182 <gets+0x22>
  for(i=0; i+1 < max; ){
 1b0:	89a6                	mv	s3,s1
 1b2:	a011                	j	1b6 <gets+0x56>
 1b4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1b6:	99de                	add	s3,s3,s7
 1b8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1bc:	855e                	mv	a0,s7
 1be:	60e6                	ld	ra,88(sp)
 1c0:	6446                	ld	s0,80(sp)
 1c2:	64a6                	ld	s1,72(sp)
 1c4:	6906                	ld	s2,64(sp)
 1c6:	79e2                	ld	s3,56(sp)
 1c8:	7a42                	ld	s4,48(sp)
 1ca:	7aa2                	ld	s5,40(sp)
 1cc:	7b02                	ld	s6,32(sp)
 1ce:	6be2                	ld	s7,24(sp)
 1d0:	6125                	add	sp,sp,96
 1d2:	8082                	ret

00000000000001d4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1d4:	1101                	add	sp,sp,-32
 1d6:	ec06                	sd	ra,24(sp)
 1d8:	e822                	sd	s0,16(sp)
 1da:	e426                	sd	s1,8(sp)
 1dc:	e04a                	sd	s2,0(sp)
 1de:	1000                	add	s0,sp,32
 1e0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e2:	4581                	li	a1,0
 1e4:	00000097          	auipc	ra,0x0
 1e8:	170080e7          	jalr	368(ra) # 354 <open>
  if(fd < 0)
 1ec:	02054563          	bltz	a0,216 <stat+0x42>
 1f0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1f2:	85ca                	mv	a1,s2
 1f4:	00000097          	auipc	ra,0x0
 1f8:	178080e7          	jalr	376(ra) # 36c <fstat>
 1fc:	892a                	mv	s2,a0
  close(fd);
 1fe:	8526                	mv	a0,s1
 200:	00000097          	auipc	ra,0x0
 204:	13c080e7          	jalr	316(ra) # 33c <close>
  return r;
}
 208:	854a                	mv	a0,s2
 20a:	60e2                	ld	ra,24(sp)
 20c:	6442                	ld	s0,16(sp)
 20e:	64a2                	ld	s1,8(sp)
 210:	6902                	ld	s2,0(sp)
 212:	6105                	add	sp,sp,32
 214:	8082                	ret
    return -1;
 216:	597d                	li	s2,-1
 218:	bfc5                	j	208 <stat+0x34>

000000000000021a <atoi>:

int
atoi(const char *s)
{
 21a:	1141                	add	sp,sp,-16
 21c:	e422                	sd	s0,8(sp)
 21e:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 220:	00054683          	lbu	a3,0(a0)
 224:	fd06879b          	addw	a5,a3,-48
 228:	0ff7f793          	zext.b	a5,a5
 22c:	4625                	li	a2,9
 22e:	02f66863          	bltu	a2,a5,25e <atoi+0x44>
 232:	872a                	mv	a4,a0
  n = 0;
 234:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 236:	0705                	add	a4,a4,1
 238:	0025179b          	sllw	a5,a0,0x2
 23c:	9fa9                	addw	a5,a5,a0
 23e:	0017979b          	sllw	a5,a5,0x1
 242:	9fb5                	addw	a5,a5,a3
 244:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 248:	00074683          	lbu	a3,0(a4)
 24c:	fd06879b          	addw	a5,a3,-48
 250:	0ff7f793          	zext.b	a5,a5
 254:	fef671e3          	bgeu	a2,a5,236 <atoi+0x1c>
  return n;
}
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	add	sp,sp,16
 25c:	8082                	ret
  n = 0;
 25e:	4501                	li	a0,0
 260:	bfe5                	j	258 <atoi+0x3e>

0000000000000262 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 262:	1141                	add	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 268:	02b57463          	bgeu	a0,a1,290 <memmove+0x2e>
    while(n-- > 0)
 26c:	00c05f63          	blez	a2,28a <memmove+0x28>
 270:	1602                	sll	a2,a2,0x20
 272:	9201                	srl	a2,a2,0x20
 274:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 278:	872a                	mv	a4,a0
      *dst++ = *src++;
 27a:	0585                	add	a1,a1,1
 27c:	0705                	add	a4,a4,1
 27e:	fff5c683          	lbu	a3,-1(a1)
 282:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 286:	fee79ae3          	bne	a5,a4,27a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 28a:	6422                	ld	s0,8(sp)
 28c:	0141                	add	sp,sp,16
 28e:	8082                	ret
    dst += n;
 290:	00c50733          	add	a4,a0,a2
    src += n;
 294:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 296:	fec05ae3          	blez	a2,28a <memmove+0x28>
 29a:	fff6079b          	addw	a5,a2,-1
 29e:	1782                	sll	a5,a5,0x20
 2a0:	9381                	srl	a5,a5,0x20
 2a2:	fff7c793          	not	a5,a5
 2a6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2a8:	15fd                	add	a1,a1,-1
 2aa:	177d                	add	a4,a4,-1
 2ac:	0005c683          	lbu	a3,0(a1)
 2b0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2b4:	fee79ae3          	bne	a5,a4,2a8 <memmove+0x46>
 2b8:	bfc9                	j	28a <memmove+0x28>

00000000000002ba <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2ba:	1141                	add	sp,sp,-16
 2bc:	e422                	sd	s0,8(sp)
 2be:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c0:	ca05                	beqz	a2,2f0 <memcmp+0x36>
 2c2:	fff6069b          	addw	a3,a2,-1
 2c6:	1682                	sll	a3,a3,0x20
 2c8:	9281                	srl	a3,a3,0x20
 2ca:	0685                	add	a3,a3,1
 2cc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ce:	00054783          	lbu	a5,0(a0)
 2d2:	0005c703          	lbu	a4,0(a1)
 2d6:	00e79863          	bne	a5,a4,2e6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2da:	0505                	add	a0,a0,1
    p2++;
 2dc:	0585                	add	a1,a1,1
  while (n-- > 0) {
 2de:	fed518e3          	bne	a0,a3,2ce <memcmp+0x14>
  }
  return 0;
 2e2:	4501                	li	a0,0
 2e4:	a019                	j	2ea <memcmp+0x30>
      return *p1 - *p2;
 2e6:	40e7853b          	subw	a0,a5,a4
}
 2ea:	6422                	ld	s0,8(sp)
 2ec:	0141                	add	sp,sp,16
 2ee:	8082                	ret
  return 0;
 2f0:	4501                	li	a0,0
 2f2:	bfe5                	j	2ea <memcmp+0x30>

00000000000002f4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f4:	1141                	add	sp,sp,-16
 2f6:	e406                	sd	ra,8(sp)
 2f8:	e022                	sd	s0,0(sp)
 2fa:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 2fc:	00000097          	auipc	ra,0x0
 300:	f66080e7          	jalr	-154(ra) # 262 <memmove>
}
 304:	60a2                	ld	ra,8(sp)
 306:	6402                	ld	s0,0(sp)
 308:	0141                	add	sp,sp,16
 30a:	8082                	ret

000000000000030c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 30c:	4885                	li	a7,1
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <exit>:
.global exit
exit:
 li a7, SYS_exit
 314:	4889                	li	a7,2
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <wait>:
.global wait
wait:
 li a7, SYS_wait
 31c:	488d                	li	a7,3
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 324:	4891                	li	a7,4
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <read>:
.global read
read:
 li a7, SYS_read
 32c:	4895                	li	a7,5
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <write>:
.global write
write:
 li a7, SYS_write
 334:	48c1                	li	a7,16
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <close>:
.global close
close:
 li a7, SYS_close
 33c:	48d5                	li	a7,21
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <kill>:
.global kill
kill:
 li a7, SYS_kill
 344:	4899                	li	a7,6
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <exec>:
.global exec
exec:
 li a7, SYS_exec
 34c:	489d                	li	a7,7
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <open>:
.global open
open:
 li a7, SYS_open
 354:	48bd                	li	a7,15
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 35c:	48c5                	li	a7,17
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 364:	48c9                	li	a7,18
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 36c:	48a1                	li	a7,8
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <link>:
.global link
link:
 li a7, SYS_link
 374:	48cd                	li	a7,19
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 37c:	48d1                	li	a7,20
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 384:	48a5                	li	a7,9
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <dup>:
.global dup
dup:
 li a7, SYS_dup
 38c:	48a9                	li	a7,10
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 394:	48ad                	li	a7,11
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 39c:	48b1                	li	a7,12
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3a4:	48b5                	li	a7,13
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ac:	48b9                	li	a7,14
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <waitx>:
.global waitx
waitx:
 li a7, SYS_waitx
 3b4:	48d9                	li	a7,22
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3bc:	1101                	add	sp,sp,-32
 3be:	ec06                	sd	ra,24(sp)
 3c0:	e822                	sd	s0,16(sp)
 3c2:	1000                	add	s0,sp,32
 3c4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c8:	4605                	li	a2,1
 3ca:	fef40593          	add	a1,s0,-17
 3ce:	00000097          	auipc	ra,0x0
 3d2:	f66080e7          	jalr	-154(ra) # 334 <write>
}
 3d6:	60e2                	ld	ra,24(sp)
 3d8:	6442                	ld	s0,16(sp)
 3da:	6105                	add	sp,sp,32
 3dc:	8082                	ret

00000000000003de <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3de:	7139                	add	sp,sp,-64
 3e0:	fc06                	sd	ra,56(sp)
 3e2:	f822                	sd	s0,48(sp)
 3e4:	f426                	sd	s1,40(sp)
 3e6:	f04a                	sd	s2,32(sp)
 3e8:	ec4e                	sd	s3,24(sp)
 3ea:	0080                	add	s0,sp,64
 3ec:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3ee:	c299                	beqz	a3,3f4 <printint+0x16>
 3f0:	0805c963          	bltz	a1,482 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3f4:	2581                	sext.w	a1,a1
  neg = 0;
 3f6:	4881                	li	a7,0
 3f8:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 3fc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3fe:	2601                	sext.w	a2,a2
 400:	00000517          	auipc	a0,0x0
 404:	4a050513          	add	a0,a0,1184 # 8a0 <digits>
 408:	883a                	mv	a6,a4
 40a:	2705                	addw	a4,a4,1
 40c:	02c5f7bb          	remuw	a5,a1,a2
 410:	1782                	sll	a5,a5,0x20
 412:	9381                	srl	a5,a5,0x20
 414:	97aa                	add	a5,a5,a0
 416:	0007c783          	lbu	a5,0(a5)
 41a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 41e:	0005879b          	sext.w	a5,a1
 422:	02c5d5bb          	divuw	a1,a1,a2
 426:	0685                	add	a3,a3,1
 428:	fec7f0e3          	bgeu	a5,a2,408 <printint+0x2a>
  if(neg)
 42c:	00088c63          	beqz	a7,444 <printint+0x66>
    buf[i++] = '-';
 430:	fd070793          	add	a5,a4,-48
 434:	00878733          	add	a4,a5,s0
 438:	02d00793          	li	a5,45
 43c:	fef70823          	sb	a5,-16(a4)
 440:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 444:	02e05863          	blez	a4,474 <printint+0x96>
 448:	fc040793          	add	a5,s0,-64
 44c:	00e78933          	add	s2,a5,a4
 450:	fff78993          	add	s3,a5,-1
 454:	99ba                	add	s3,s3,a4
 456:	377d                	addw	a4,a4,-1
 458:	1702                	sll	a4,a4,0x20
 45a:	9301                	srl	a4,a4,0x20
 45c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 460:	fff94583          	lbu	a1,-1(s2)
 464:	8526                	mv	a0,s1
 466:	00000097          	auipc	ra,0x0
 46a:	f56080e7          	jalr	-170(ra) # 3bc <putc>
  while(--i >= 0)
 46e:	197d                	add	s2,s2,-1
 470:	ff3918e3          	bne	s2,s3,460 <printint+0x82>
}
 474:	70e2                	ld	ra,56(sp)
 476:	7442                	ld	s0,48(sp)
 478:	74a2                	ld	s1,40(sp)
 47a:	7902                	ld	s2,32(sp)
 47c:	69e2                	ld	s3,24(sp)
 47e:	6121                	add	sp,sp,64
 480:	8082                	ret
    x = -xx;
 482:	40b005bb          	negw	a1,a1
    neg = 1;
 486:	4885                	li	a7,1
    x = -xx;
 488:	bf85                	j	3f8 <printint+0x1a>

000000000000048a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 48a:	715d                	add	sp,sp,-80
 48c:	e486                	sd	ra,72(sp)
 48e:	e0a2                	sd	s0,64(sp)
 490:	fc26                	sd	s1,56(sp)
 492:	f84a                	sd	s2,48(sp)
 494:	f44e                	sd	s3,40(sp)
 496:	f052                	sd	s4,32(sp)
 498:	ec56                	sd	s5,24(sp)
 49a:	e85a                	sd	s6,16(sp)
 49c:	e45e                	sd	s7,8(sp)
 49e:	e062                	sd	s8,0(sp)
 4a0:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4a2:	0005c903          	lbu	s2,0(a1)
 4a6:	18090c63          	beqz	s2,63e <vprintf+0x1b4>
 4aa:	8aaa                	mv	s5,a0
 4ac:	8bb2                	mv	s7,a2
 4ae:	00158493          	add	s1,a1,1
  state = 0;
 4b2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4b4:	02500a13          	li	s4,37
 4b8:	4b55                	li	s6,21
 4ba:	a839                	j	4d8 <vprintf+0x4e>
        putc(fd, c);
 4bc:	85ca                	mv	a1,s2
 4be:	8556                	mv	a0,s5
 4c0:	00000097          	auipc	ra,0x0
 4c4:	efc080e7          	jalr	-260(ra) # 3bc <putc>
 4c8:	a019                	j	4ce <vprintf+0x44>
    } else if(state == '%'){
 4ca:	01498d63          	beq	s3,s4,4e4 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4ce:	0485                	add	s1,s1,1
 4d0:	fff4c903          	lbu	s2,-1(s1)
 4d4:	16090563          	beqz	s2,63e <vprintf+0x1b4>
    if(state == 0){
 4d8:	fe0999e3          	bnez	s3,4ca <vprintf+0x40>
      if(c == '%'){
 4dc:	ff4910e3          	bne	s2,s4,4bc <vprintf+0x32>
        state = '%';
 4e0:	89d2                	mv	s3,s4
 4e2:	b7f5                	j	4ce <vprintf+0x44>
      if(c == 'd'){
 4e4:	13490263          	beq	s2,s4,608 <vprintf+0x17e>
 4e8:	f9d9079b          	addw	a5,s2,-99
 4ec:	0ff7f793          	zext.b	a5,a5
 4f0:	12fb6563          	bltu	s6,a5,61a <vprintf+0x190>
 4f4:	f9d9079b          	addw	a5,s2,-99
 4f8:	0ff7f713          	zext.b	a4,a5
 4fc:	10eb6f63          	bltu	s6,a4,61a <vprintf+0x190>
 500:	00271793          	sll	a5,a4,0x2
 504:	00000717          	auipc	a4,0x0
 508:	34470713          	add	a4,a4,836 # 848 <malloc+0x10c>
 50c:	97ba                	add	a5,a5,a4
 50e:	439c                	lw	a5,0(a5)
 510:	97ba                	add	a5,a5,a4
 512:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 514:	008b8913          	add	s2,s7,8
 518:	4685                	li	a3,1
 51a:	4629                	li	a2,10
 51c:	000ba583          	lw	a1,0(s7)
 520:	8556                	mv	a0,s5
 522:	00000097          	auipc	ra,0x0
 526:	ebc080e7          	jalr	-324(ra) # 3de <printint>
 52a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 52c:	4981                	li	s3,0
 52e:	b745                	j	4ce <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 530:	008b8913          	add	s2,s7,8
 534:	4681                	li	a3,0
 536:	4629                	li	a2,10
 538:	000ba583          	lw	a1,0(s7)
 53c:	8556                	mv	a0,s5
 53e:	00000097          	auipc	ra,0x0
 542:	ea0080e7          	jalr	-352(ra) # 3de <printint>
 546:	8bca                	mv	s7,s2
      state = 0;
 548:	4981                	li	s3,0
 54a:	b751                	j	4ce <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 54c:	008b8913          	add	s2,s7,8
 550:	4681                	li	a3,0
 552:	4641                	li	a2,16
 554:	000ba583          	lw	a1,0(s7)
 558:	8556                	mv	a0,s5
 55a:	00000097          	auipc	ra,0x0
 55e:	e84080e7          	jalr	-380(ra) # 3de <printint>
 562:	8bca                	mv	s7,s2
      state = 0;
 564:	4981                	li	s3,0
 566:	b7a5                	j	4ce <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 568:	008b8c13          	add	s8,s7,8
 56c:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 570:	03000593          	li	a1,48
 574:	8556                	mv	a0,s5
 576:	00000097          	auipc	ra,0x0
 57a:	e46080e7          	jalr	-442(ra) # 3bc <putc>
  putc(fd, 'x');
 57e:	07800593          	li	a1,120
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	e38080e7          	jalr	-456(ra) # 3bc <putc>
 58c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 58e:	00000b97          	auipc	s7,0x0
 592:	312b8b93          	add	s7,s7,786 # 8a0 <digits>
 596:	03c9d793          	srl	a5,s3,0x3c
 59a:	97de                	add	a5,a5,s7
 59c:	0007c583          	lbu	a1,0(a5)
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	e1a080e7          	jalr	-486(ra) # 3bc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5aa:	0992                	sll	s3,s3,0x4
 5ac:	397d                	addw	s2,s2,-1
 5ae:	fe0914e3          	bnez	s2,596 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5b2:	8be2                	mv	s7,s8
      state = 0;
 5b4:	4981                	li	s3,0
 5b6:	bf21                	j	4ce <vprintf+0x44>
        s = va_arg(ap, char*);
 5b8:	008b8993          	add	s3,s7,8
 5bc:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5c0:	02090163          	beqz	s2,5e2 <vprintf+0x158>
        while(*s != 0){
 5c4:	00094583          	lbu	a1,0(s2)
 5c8:	c9a5                	beqz	a1,638 <vprintf+0x1ae>
          putc(fd, *s);
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	df0080e7          	jalr	-528(ra) # 3bc <putc>
          s++;
 5d4:	0905                	add	s2,s2,1
        while(*s != 0){
 5d6:	00094583          	lbu	a1,0(s2)
 5da:	f9e5                	bnez	a1,5ca <vprintf+0x140>
        s = va_arg(ap, char*);
 5dc:	8bce                	mv	s7,s3
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	b5fd                	j	4ce <vprintf+0x44>
          s = "(null)";
 5e2:	00000917          	auipc	s2,0x0
 5e6:	25e90913          	add	s2,s2,606 # 840 <malloc+0x104>
        while(*s != 0){
 5ea:	02800593          	li	a1,40
 5ee:	bff1                	j	5ca <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 5f0:	008b8913          	add	s2,s7,8
 5f4:	000bc583          	lbu	a1,0(s7)
 5f8:	8556                	mv	a0,s5
 5fa:	00000097          	auipc	ra,0x0
 5fe:	dc2080e7          	jalr	-574(ra) # 3bc <putc>
 602:	8bca                	mv	s7,s2
      state = 0;
 604:	4981                	li	s3,0
 606:	b5e1                	j	4ce <vprintf+0x44>
        putc(fd, c);
 608:	02500593          	li	a1,37
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	dae080e7          	jalr	-594(ra) # 3bc <putc>
      state = 0;
 616:	4981                	li	s3,0
 618:	bd5d                	j	4ce <vprintf+0x44>
        putc(fd, '%');
 61a:	02500593          	li	a1,37
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	d9c080e7          	jalr	-612(ra) # 3bc <putc>
        putc(fd, c);
 628:	85ca                	mv	a1,s2
 62a:	8556                	mv	a0,s5
 62c:	00000097          	auipc	ra,0x0
 630:	d90080e7          	jalr	-624(ra) # 3bc <putc>
      state = 0;
 634:	4981                	li	s3,0
 636:	bd61                	j	4ce <vprintf+0x44>
        s = va_arg(ap, char*);
 638:	8bce                	mv	s7,s3
      state = 0;
 63a:	4981                	li	s3,0
 63c:	bd49                	j	4ce <vprintf+0x44>
    }
  }
}
 63e:	60a6                	ld	ra,72(sp)
 640:	6406                	ld	s0,64(sp)
 642:	74e2                	ld	s1,56(sp)
 644:	7942                	ld	s2,48(sp)
 646:	79a2                	ld	s3,40(sp)
 648:	7a02                	ld	s4,32(sp)
 64a:	6ae2                	ld	s5,24(sp)
 64c:	6b42                	ld	s6,16(sp)
 64e:	6ba2                	ld	s7,8(sp)
 650:	6c02                	ld	s8,0(sp)
 652:	6161                	add	sp,sp,80
 654:	8082                	ret

0000000000000656 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 656:	715d                	add	sp,sp,-80
 658:	ec06                	sd	ra,24(sp)
 65a:	e822                	sd	s0,16(sp)
 65c:	1000                	add	s0,sp,32
 65e:	e010                	sd	a2,0(s0)
 660:	e414                	sd	a3,8(s0)
 662:	e818                	sd	a4,16(s0)
 664:	ec1c                	sd	a5,24(s0)
 666:	03043023          	sd	a6,32(s0)
 66a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 66e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 672:	8622                	mv	a2,s0
 674:	00000097          	auipc	ra,0x0
 678:	e16080e7          	jalr	-490(ra) # 48a <vprintf>
}
 67c:	60e2                	ld	ra,24(sp)
 67e:	6442                	ld	s0,16(sp)
 680:	6161                	add	sp,sp,80
 682:	8082                	ret

0000000000000684 <printf>:

void
printf(const char *fmt, ...)
{
 684:	711d                	add	sp,sp,-96
 686:	ec06                	sd	ra,24(sp)
 688:	e822                	sd	s0,16(sp)
 68a:	1000                	add	s0,sp,32
 68c:	e40c                	sd	a1,8(s0)
 68e:	e810                	sd	a2,16(s0)
 690:	ec14                	sd	a3,24(s0)
 692:	f018                	sd	a4,32(s0)
 694:	f41c                	sd	a5,40(s0)
 696:	03043823          	sd	a6,48(s0)
 69a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 69e:	00840613          	add	a2,s0,8
 6a2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6a6:	85aa                	mv	a1,a0
 6a8:	4505                	li	a0,1
 6aa:	00000097          	auipc	ra,0x0
 6ae:	de0080e7          	jalr	-544(ra) # 48a <vprintf>
}
 6b2:	60e2                	ld	ra,24(sp)
 6b4:	6442                	ld	s0,16(sp)
 6b6:	6125                	add	sp,sp,96
 6b8:	8082                	ret

00000000000006ba <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6ba:	1141                	add	sp,sp,-16
 6bc:	e422                	sd	s0,8(sp)
 6be:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6c0:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c4:	00001797          	auipc	a5,0x1
 6c8:	93c7b783          	ld	a5,-1732(a5) # 1000 <freep>
 6cc:	a02d                	j	6f6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6ce:	4618                	lw	a4,8(a2)
 6d0:	9f2d                	addw	a4,a4,a1
 6d2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d6:	6398                	ld	a4,0(a5)
 6d8:	6310                	ld	a2,0(a4)
 6da:	a83d                	j	718 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6dc:	ff852703          	lw	a4,-8(a0)
 6e0:	9f31                	addw	a4,a4,a2
 6e2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6e4:	ff053683          	ld	a3,-16(a0)
 6e8:	a091                	j	72c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ea:	6398                	ld	a4,0(a5)
 6ec:	00e7e463          	bltu	a5,a4,6f4 <free+0x3a>
 6f0:	00e6ea63          	bltu	a3,a4,704 <free+0x4a>
{
 6f4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f6:	fed7fae3          	bgeu	a5,a3,6ea <free+0x30>
 6fa:	6398                	ld	a4,0(a5)
 6fc:	00e6e463          	bltu	a3,a4,704 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 700:	fee7eae3          	bltu	a5,a4,6f4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 704:	ff852583          	lw	a1,-8(a0)
 708:	6390                	ld	a2,0(a5)
 70a:	02059813          	sll	a6,a1,0x20
 70e:	01c85713          	srl	a4,a6,0x1c
 712:	9736                	add	a4,a4,a3
 714:	fae60de3          	beq	a2,a4,6ce <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 718:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 71c:	4790                	lw	a2,8(a5)
 71e:	02061593          	sll	a1,a2,0x20
 722:	01c5d713          	srl	a4,a1,0x1c
 726:	973e                	add	a4,a4,a5
 728:	fae68ae3          	beq	a3,a4,6dc <free+0x22>
    p->s.ptr = bp->s.ptr;
 72c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 72e:	00001717          	auipc	a4,0x1
 732:	8cf73923          	sd	a5,-1838(a4) # 1000 <freep>
}
 736:	6422                	ld	s0,8(sp)
 738:	0141                	add	sp,sp,16
 73a:	8082                	ret

000000000000073c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 73c:	7139                	add	sp,sp,-64
 73e:	fc06                	sd	ra,56(sp)
 740:	f822                	sd	s0,48(sp)
 742:	f426                	sd	s1,40(sp)
 744:	f04a                	sd	s2,32(sp)
 746:	ec4e                	sd	s3,24(sp)
 748:	e852                	sd	s4,16(sp)
 74a:	e456                	sd	s5,8(sp)
 74c:	e05a                	sd	s6,0(sp)
 74e:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 750:	02051493          	sll	s1,a0,0x20
 754:	9081                	srl	s1,s1,0x20
 756:	04bd                	add	s1,s1,15
 758:	8091                	srl	s1,s1,0x4
 75a:	0014899b          	addw	s3,s1,1
 75e:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 760:	00001517          	auipc	a0,0x1
 764:	8a053503          	ld	a0,-1888(a0) # 1000 <freep>
 768:	c515                	beqz	a0,794 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 76a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 76c:	4798                	lw	a4,8(a5)
 76e:	02977f63          	bgeu	a4,s1,7ac <malloc+0x70>
  if(nu < 4096)
 772:	8a4e                	mv	s4,s3
 774:	0009871b          	sext.w	a4,s3
 778:	6685                	lui	a3,0x1
 77a:	00d77363          	bgeu	a4,a3,780 <malloc+0x44>
 77e:	6a05                	lui	s4,0x1
 780:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 784:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 788:	00001917          	auipc	s2,0x1
 78c:	87890913          	add	s2,s2,-1928 # 1000 <freep>
  if(p == (char*)-1)
 790:	5afd                	li	s5,-1
 792:	a895                	j	806 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 794:	00001797          	auipc	a5,0x1
 798:	87c78793          	add	a5,a5,-1924 # 1010 <base>
 79c:	00001717          	auipc	a4,0x1
 7a0:	86f73223          	sd	a5,-1948(a4) # 1000 <freep>
 7a4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7a6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7aa:	b7e1                	j	772 <malloc+0x36>
      if(p->s.size == nunits)
 7ac:	02e48c63          	beq	s1,a4,7e4 <malloc+0xa8>
        p->s.size -= nunits;
 7b0:	4137073b          	subw	a4,a4,s3
 7b4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7b6:	02071693          	sll	a3,a4,0x20
 7ba:	01c6d713          	srl	a4,a3,0x1c
 7be:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7c0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7c4:	00001717          	auipc	a4,0x1
 7c8:	82a73e23          	sd	a0,-1988(a4) # 1000 <freep>
      return (void*)(p + 1);
 7cc:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7d0:	70e2                	ld	ra,56(sp)
 7d2:	7442                	ld	s0,48(sp)
 7d4:	74a2                	ld	s1,40(sp)
 7d6:	7902                	ld	s2,32(sp)
 7d8:	69e2                	ld	s3,24(sp)
 7da:	6a42                	ld	s4,16(sp)
 7dc:	6aa2                	ld	s5,8(sp)
 7de:	6b02                	ld	s6,0(sp)
 7e0:	6121                	add	sp,sp,64
 7e2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7e4:	6398                	ld	a4,0(a5)
 7e6:	e118                	sd	a4,0(a0)
 7e8:	bff1                	j	7c4 <malloc+0x88>
  hp->s.size = nu;
 7ea:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7ee:	0541                	add	a0,a0,16
 7f0:	00000097          	auipc	ra,0x0
 7f4:	eca080e7          	jalr	-310(ra) # 6ba <free>
  return freep;
 7f8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7fc:	d971                	beqz	a0,7d0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 800:	4798                	lw	a4,8(a5)
 802:	fa9775e3          	bgeu	a4,s1,7ac <malloc+0x70>
    if(p == freep)
 806:	00093703          	ld	a4,0(s2)
 80a:	853e                	mv	a0,a5
 80c:	fef719e3          	bne	a4,a5,7fe <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 810:	8552                	mv	a0,s4
 812:	00000097          	auipc	ra,0x0
 816:	b8a080e7          	jalr	-1142(ra) # 39c <sbrk>
  if(p == (char*)-1)
 81a:	fd5518e3          	bne	a0,s5,7ea <malloc+0xae>
        return 0;
 81e:	4501                	li	a0,0
 820:	bf45                	j	7d0 <malloc+0x94>
