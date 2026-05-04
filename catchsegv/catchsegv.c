#include <linux/prctl.h>
#include <signal.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/prctl.h>
#include <sys/resource.h>

static char altstack[SIGSTKSZ * 4];

static void handler(int sig)
{
    signal(sig, SIG_DFL);
    signal(SIGABRT, SIG_DFL);
}

__attribute__((constructor(101)))
static void force_core(void){
    struct rlimit rl = {RLIM_INFINITY, RLIM_INFINITY};
    setrlimit(RLIMIT_CORE, &rl);
    write(1, "seisiesieiseise\n", 16);
    prctl(PR_SET_DUMPABLE, 1);
    stack_t ss ={
        .ss_sp = altstack,
        .ss_size = sizeof(altstack),
        .ss_flags = 0,
    };
    sigaltstack(&ss, NULL);
    struct sigaction sa = {
        .sa_handler = handler,
        .sa_flags = SA_ONSTACK | SA_RESETHAND
    };
    sigemptyset(&sa.sa_mask);
    sigaction(SIGSEGV, &sa, NULL);
    sigaction(SIGBUS,  &sa, NULL);
    sigaction(SIGFPE,  &sa, NULL);
    sigaction(SIGILL,  &sa, NULL);
}