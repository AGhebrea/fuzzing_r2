#include <dlfcn.h>
#include <fcntl.h> /* Definition of AT_* constants */
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>
#include <stdio.h>
#include <assert.h>
#include <stdarg.h>
#include <stdlib.h>

#define FILE_DESC_MAGIC_VAL 999
__attribute__((weak)) unsigned char*  _buf_afl_fuzz_testcase_buf = 0;
__attribute__((weak)) unsigned int    _buf_afl_fuzz_testcase_buf_len = 0;
char* target = NULL;
off_t where = 0;
int hooked_fd = 0;
int hooked = 0;
const char* debugfile = "/tmp/libc_debug.log";
FILE* debugfile_handle = NULL;
int debugging = 0;

int     (*open_addr)(const char*, int) = NULL;
ssize_t (*read_addr)(int fd, void* buf, size_t count) = NULL;
int     (*stat_addr)(const char *restrict path, struct stat *restrict statbuf);
int     (*fstat_addr)(int fd, struct stat *statbuf);
int     (*fstatat_addr)(int dirfd, const char *restrict path, struct stat *restrict statbuf, int flags);
off_t   (*seek_addr)(int fd, off_t offset, int whence);
ssize_t (*write_addr)(int __fd, const void *__buf, size_t __n);
size_t  (*fwrite_addr)(const void* ptr, size_t size, size_t n, FILE *restrict stream);
int     (*fputc_addr)(int c, FILE *stream);
int     (*putc_addr)(int c, FILE *stream);
int     (*putchar_addr)(int c);
int     (*fputs_addr)(const char *restrict s, FILE *restrict stream);
int     (*puts_addr)(const char *s);
int     (*vprintf_addr)(const char *restrict format, va_list ap);
int     (*vfprintf_addr)(FILE *restrict stream, const char *restrict format, va_list ap);
int     (*vdprintf_addr)(int fd, const char *restrict format, va_list ap);

#ifdef HOOK_FILE_OPERATIONS
__asm__(".symver hook_open, open@GLIBC_2.2.5");
__asm__(".symver hook_open, open64@GLIBC_2.2.5");
__asm__(".symver hook_read, read@GLIBC_2.2.5");
__asm__(".symver hook_stat, stat@GLIBC_2.2.5");
__asm__(".symver hook_stat, stat64@@GLIBC_2.33");
__asm__(".symver hook_stat, stat@@GLIBC_2.33");
__asm__(".symver hook_fstat, fstat@GLIBC_2.2.5");
__asm__(".symver hook_fstat, fstat@@GLIBC_2.33");
__asm__(".symver hook_fstat, fstat64@@GLIBC_2.33");
__asm__(".symver hook_fstatat, fstatat@GLIBC_2.2.5");
__asm__(".symver hook_seek, seek@GLIBC_2.2.5");
__asm__(".symver hook_seek, lseek64@GLIBC_2.2.5");
__asm__(".symver hook_seek, lseek@GLIBC_2.2.5");
int open(const char* __file, int __oflag, ...) __attribute__((alias("hook_open")));
int open64(const char* __file, int __oflag, ...) __attribute__((alias("hook_open")));
int __libc_open64(const char* __file, int __oflag, ...) __attribute__((alias("hook_open")));
ssize_t __GI___libc_read(int fd, void* buf, size_t count) __attribute__((alias("hook_read")));
int __GI___stat64(const char *restrict path, struct stat *restrict statbuf) __attribute__((alias("hook_stat")));
off_t lseek64(int fd, off_t offset, int whence) __attribute__((alias("hook_seek")));
int __GI___fstat64(int fd, struct stat *restrict statbuf) __attribute__((alias("hook_fstat")));
int __GI___fstatat64(int dirfd, const char *restrict path, struct stat *restrict statbuf, int flags)__attribute__((alias("hook_fstatat")));
int fstatat64(int dirfd, const char *restrict path, struct stat *restrict statbuf, int flags)__attribute__((alias("hook_fstatat")));
#endif


#ifdef HOOK_WRITING
__asm__(".symver hook_write, write@GLIBC_2.2.5");
__asm__(".symver hook_fwrite, fwrite@GLIBC_2.2.5");
__asm__(".symver hook_fputc, fputc@GLIBC_2.2.5");
__asm__(".symver hook_putc, putc@GLIBC_2.2.5");
__asm__(".symver hook_putchar, putchar@GLIBC_2.2.5");
__asm__(".symver hook_fputs, fputs@GLIBC_2.2.5");
__asm__(".symver hook_puts, puts@GLIBC_2.2.5");
__asm__(".symver hook_printf, printf@GLIBC_2.2.5");
__asm__(".symver hook_fprintf, fprintf@GLIBC_2.2.5");
__asm__(".symver hook_dprintf, dprintf@GLIBC_2.2.5");
__asm__(".symver hook_vprintf, vprintf@GLIBC_2.2.5");
__asm__(".symver hook_vfprintf, vfprintf@GLIBC_2.2.5");
__asm__(".symver hook_vdprintf, vdprintf@GLIBC_2.2.5");
ssize_t __GI___libc_write(int __fd, const void *__buf, size_t __n)__attribute__((alias("hook_write")));
ssize_t write(int __fd, const void *__buf, size_t __n)__attribute__((alias("hook_write")));
int __printf(const char *restrict format, ...)__attribute__((alias("hook_printf")));
#endif

void reset_hooked_libc_state()
{
    where = 0;
    hooked_fd = 0;
    hooked = 0;
}

int hook_printf(const char *restrict format, ...)
{
    int n;
    va_list ap;
    va_start(ap, format);
    n = vsnprintf(NULL, 0, format, ap);
    va_end(ap);
    return n;
}

int hook_fprintf(FILE *restrict stream, const char *restrict format, ...)
{
    int n;
    va_list ap;
    va_start(ap, format);
    if((void*)stream == (void*)stdout || (void*)stream == (void*)stderr){
        n = vsnprintf(NULL, 0, format, ap);
        va_end(ap);
        return n;
    }
    n = vfprintf_addr(stream, format, ap);
    va_end(ap);
    return n;
}

int hook_dprintf(int fd, const char *restrict format, ...)
{
    int n;
    va_list ap;
    va_start(ap, format);
    if(fd == 1 || fd == 0){
        n = vsnprintf(NULL, 0, format, ap);
        va_end(ap);
        return n;
    }
    n = vdprintf_addr(fd, format, ap);
    va_end(ap);
    return n;
}

int hook_vprintf(const char *restrict format, va_list ap)
{
    return vsnprintf(NULL, 0, format, ap);
}

int hook_vfprintf(FILE *restrict stream, const char *restrict format, va_list ap)
{
    if((void*)stream == (void*)stdout || (void*)stream == (void*)stderr){
        return vsnprintf(NULL, 0, format, ap);
    }
    return vfprintf_addr(stream, format, ap);
}

void hook_debug_fprintf(const char *restrict format, ...)
{
    va_list ap;
    if(debugging){
        va_start(ap, format);
        hook_vfprintf(debugfile_handle, format, ap);
        fflush(debugfile_handle);
        va_end(ap);
    }
}

int hook_vdprintf(int fd, const char *restrict format, va_list ap)
{
    if(fd == 1 || fd == 0){
        return vsnprintf(NULL, 0, format, ap);
    }
    return vdprintf_addr(fd, format, ap);
}

int hook_fputc(int c, FILE *stream)
{
    if((void*)stream == (void*)stdout || (void*)stream == (void*)stderr){
        return (int)((unsigned char)c);
    }
    return fputc_addr(c, stream);
}

int hook_putc(int c, FILE *stream)
{
    if((void*)stream == (void*)stdout || (void*)stream == (void*)stderr){
        return (int)((unsigned char)c);
    }
    return putc_addr(c, stream);
}

int hook_putchar(int c)
{
    return (int)((unsigned char)c);
}

int hook_fputs(const char *restrict s, FILE *restrict stream)
{
    if((void*)stream == (void*)stdout || (void*)stream == (void*)stderr){
        return 0;
    }
    return fputs_addr(s, stream);
}

int hook_puts(const char *s)
{
    return 0;
}

int hook_open(const char *__file, int __oflag, ...){
    int ret;
    hook_debug_fprintf("hook_open %s\n", __file);
    if(!strcmp(target, __file)){
        hook_debug_fprintf("hook_open spoof path\n");         
        hooked_fd = FILE_DESC_MAGIC_VAL;
        hooked = 1;
        return hooked_fd;
    }else{
        ret = open_addr(__file, __oflag);
    }
    if(ret == FILE_DESC_MAGIC_VAL){
        assert(0);
    }
    return ret;
}

// TODO: keep track of dups to 1, 2
ssize_t hook_write (int __fd, const void *__buf, size_t __n)
{
    hook_debug_fprintf("hook_write %d [%s]\n", __fd, (char*)__buf);
    if(__fd == 1 || __fd == 2){
        hook_debug_fprintf("hook_write spoof path\n");
        return __n;
    }
    return write_addr(__fd, __buf, __n);
}

size_t hook_fwrite(const void* ptr, size_t size, size_t n, FILE *restrict stream)
{
    
    hook_debug_fprintf("hook_fwrite %lx stdout:%lx stderr:%lx\n", (unsigned long)stream, (unsigned long)stdout, (unsigned long)stderr);
    
    if((void*)stream == (void*)stdout || (void*)stream == (void*)stderr){
        
        hook_debug_fprintf("hook_fwrite spoof path\n");
        
        return n;
    }
    return fwrite_addr(ptr, size, n, stream);
}

ssize_t hook_read(int fd, void* buf, size_t count)
{
    
    hook_debug_fprintf("hook_read %d\n", fd);
     
    if(hooked && fd == hooked_fd){
        
        hook_debug_fprintf("hook_read spoof path\n");
         
        // need to chekc if read overflows.
        if(where >= _buf_afl_fuzz_testcase_buf_len){
            // return EOF
            return 0;
        }
        if(count + where > _buf_afl_fuzz_testcase_buf_len){
            count = _buf_afl_fuzz_testcase_buf_len - where;
        }
        memcpy(buf, _buf_afl_fuzz_testcase_buf + where, count);
        where += count;
        return count;
    }
    return read_addr(fd, buf, count);
}

void load_statbuf(struct stat* statbuf)
{
    // taken from debugging
    statbuf->st_dev = 0x10305;
    statbuf->st_ino = 0x4a4d3c;
    statbuf->st_nlink = 0x1;
    statbuf->st_mode = 0x81ed;
    statbuf->st_uid = 0x0;
    statbuf->st_gid = 0x0;
    statbuf->__pad0 = 0x0;
    statbuf->st_rdev = 0x0;
    statbuf->st_size = _buf_afl_fuzz_testcase_buf_len;
    statbuf->st_blksize = 0x1000;
    statbuf->st_blocks = _buf_afl_fuzz_testcase_buf_len / statbuf->st_blksize;
    statbuf->st_atim.tv_sec = 0x699408e2;
    statbuf->st_atim.tv_nsec = 0x17987d99;
    statbuf->st_mtim.tv_sec = 0x684062bd;
    statbuf->st_mtim.tv_nsec = 0x0;
    statbuf->st_ctim.tv_sec = 0x6989d2eb;
    statbuf->st_ctim.tv_nsec = 0x18187fe2;
    statbuf->__glibc_reserved[0] = 0;
    statbuf->__glibc_reserved[1] = 0;
    statbuf->__glibc_reserved[2] = 0;
}

int hook_stat(const char *restrict path, struct stat *restrict statbuf)
{
    if(!strcmp(target, path)){
        load_statbuf(statbuf);
        return 0;
    }
    return stat_addr(path, statbuf);
}

int hook_fstat(int fd, struct stat *restrict statbuf)
{
    if(hooked && fd == hooked_fd){
        load_statbuf(statbuf);
        return 0;
    }
    return fstat_addr(fd, statbuf);
}

int hook_fstatat(int dirfd, const char *restrict path, struct stat *restrict statbuf, int flags)
{
    if(!strcmp(target, path)){
        load_statbuf(statbuf);
        return 0;
    }
    return fstatat_addr(dirfd, path, statbuf, flags);
}

off_t hook_seek(int fd, off_t offset, int whence)
{
    if(hooked && fd == hooked_fd){
        switch(whence){
        case SEEK_SET:
            where = offset;
            break;
        case SEEK_CUR:
            where += offset;
            break;
        case SEEK_END:
            where = _buf_afl_fuzz_testcase_buf_len + offset;
            break;
        default:
            assert(0);
        }
        return where;
    }
    return seek_addr(fd, offset, whence);
}

__attribute__((constructor)) void init_state()
{
    open_addr = dlsym(RTLD_NEXT, "open");
    read_addr = dlsym(RTLD_NEXT, "read");
    stat_addr = dlsym(RTLD_NEXT, "stat");
    fstat_addr = dlsym(RTLD_NEXT, "fstat");
    fstatat_addr = dlsym(RTLD_NEXT, "fstatat");
    seek_addr = dlsym(RTLD_NEXT, "lseek");
    write_addr = dlsym(RTLD_NEXT, "write");
    fwrite_addr = dlsym(RTLD_NEXT, "fwrite");
    fputc_addr = dlsym(RTLD_NEXT, "fputc");
    putc_addr = dlsym(RTLD_NEXT, "putc");
    putchar_addr = dlsym(RTLD_NEXT, "putchar");
    fputs_addr = dlsym(RTLD_NEXT, "fputs");
    puts_addr = dlsym(RTLD_NEXT, "puts");
    vprintf_addr = dlsym(RTLD_NEXT, "vprintf");
    vfprintf_addr = dlsym(RTLD_NEXT, "vfprintf");
    vdprintf_addr = dlsym(RTLD_NEXT, "vdprintf");
    
    if(getenv("LIBC_SHIM_DEBUG") != NULL){
        debugging = 1;
        // TODO: error handling
        debugfile_handle = fopen(debugfile, "w");
    }

    target = getenv("AFLR2_MOCKFILE");
}

__attribute__((destructor)) void destr_state()
{
    if(debugfile_handle){
        fclose(debugfile_handle);
    }
}