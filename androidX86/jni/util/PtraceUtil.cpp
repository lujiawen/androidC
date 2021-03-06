/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   PtraceUtil.cpp
 * Author: kwang
 * 
 * Created on August 4, 2016, 8:28 AM
 */
#include <stdio.h>
#include <sys/ptrace.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <assert.h>
#include <string.h>
#include <dlfcn.h>
#include <stdarg.h>
#include <string>
#include <vector>
#include <cctype>
#include <dirent.h>
#include "util.hpp"
#include "logger.h"
#include "PtraceUtil.hpp"

#define  LOG_TAG    "PtraceUtil"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

PtraceUtil::PtraceUtil() {
}


PtraceUtil::~PtraceUtil() {
}

long PtraceUtil::Attach(int _pid)
{
    pid = _pid;
    errno = 0;
    long ret = ptrace( PTRACE_ATTACH, pid, 0,0 );
    if( ret == -1){
        LOGE("Attach: %s",strerror(errno));
        return -1;
    }
    LOGD("Attach Success");
    return 0;
}

long PtraceUtil::Detach()
{
    errno = 0;
    long ret = ptrace(PTRACE_DETACH, pid, 0,0 );
    if( ret == -1){
        LOGE("Detach: %s",strerror(errno));
        return -1;
    }
    LOGD("Detach Success");
    return 0;
}

long PtraceUtil::Continue()
{
    long ret = ptrace( PTRACE_CONT, pid, 0,0 );
    if( ret == -1){
        LOGE("Continue: %s",strerror(errno));
        return -1;
    }
    LOGD("Continue Success");
    return ret;
}

MemoryBackup* PtraceUtil::FindBackupMemory(unsigned int targetAddr)
{
    for(int i=0;i<vMemoryBackup.size();i++){
        if(vMemoryBackup[i].targetAddr==targetAddr){
            LOGD("FindBackupMemory %08X found",targetAddr);
            return(&vMemoryBackup[i]);
        }
    }
    //LOGD("FindBackupMemory %08X not found",targetAddr);
    return NULL;
}

bool PtraceUtil::BackupMemory(unsigned int targetAddr,int size)
{
    LOGD("BackupMemory %08X %d",targetAddr,size);
    if(size > MEMORY_BACKUP_SIZE){
        LOGE("BackupMemory size %d > maxsize(%d)",size,MEMORY_BACKUP_SIZE);
        return false;
    }
    //printf("Before Backup Dump %08X\n",targetAddr);
    //DumpHex(targetAddr,32);
    // check if we have this before
    MemoryBackup *oldm = FindBackupMemory(targetAddr);
    if(oldm==NULL){
        LOGE("BackupMemory create new");
        MemoryBackup m;
        m.size = size;
        m.targetAddr = targetAddr;
        ReadProcessMemory(targetAddr,&m.data[0],size);
        vMemoryBackup.push_back(m);
        //printf("After Backup Dump backup\n");
        //logger.logHex(&m.data[0],32);
    }else{
        LOGE("BackupMemory reused");
        oldm->size = size;
        ReadProcessMemory(targetAddr,&oldm->data[0],size);
    }
    LOGD("BackupMemory done");
}

bool PtraceUtil::RestoreMemory(unsigned int targetAddr)
{
    LOGD("RestoreMemory %08X",targetAddr);
    //printf("Before restore Dump %08X\n",targetAddr);
    //DumpHex(targetAddr,32);
    MemoryBackup *m = FindBackupMemory(targetAddr);
    if(m!=NULL){
            WriteProcessMemory(targetAddr,&m->data[0],m->size);
            //printf("After restore Dump %08X\n",targetAddr);
            //DumpHex(targetAddr,32);
            LOGD("RestoreMemory done");
            return true;
    }
    LOGE("RestoreMemory of %08X not found",targetAddr);
    return false;
}

bool PtraceUtil::ReadProcessMemory(unsigned int addr, unsigned char *buf, int blen) {
    for (int i = 0; i < blen; i += sizeof (size_t)) {
        size_t value;
        int ret = PeekText(addr + i,&value);
        if (ret == -1) {
            LOGE("ReadProcessMemory %d %08X fail",pid,addr);
            return false;
        }
        memcpy(&buf[i], &value, sizeof (value));
    }
    return true;
}

int PtraceUtil::wordAlignSize(int size)
{
    return (size + size % sizeof (size_t));
}

bool PtraceUtil::WriteProcessMemory(unsigned int addr, unsigned char *buf, int blen) {
    long ret;
    unsigned long size = wordAlignSize(blen);
    // make sure the buffer is word aligned
    char *ptr = (char *) calloc(size, 1);
    memcpy(ptr, buf, blen);

    for (int i = 0; i < size; i += sizeof (size_t)) {
        ret = PokeText(addr + i,*(size_t *) & ptr[i]);
        if (ret == -1) {
            ::free(ptr);
            return false;
        }
    }
    ::free(ptr);
    return true;
}

int PtraceUtil::PeekText(unsigned int addr,size_t *value)
{
    errno = 0;
    long ret = ptrace( PTRACE_PEEKTEXT, pid,addr,0);
    if( ret == -1){
        if(errno){
            LOGE("PeekText: %s %d",strerror(errno),pid);
            return -1;
        }
    }
    *value = ret;
    return 0;
}

int PtraceUtil::PokeText(unsigned int addr,size_t value)
{
    errno = 0;
    long ret = ptrace( PTRACE_POKETEXT, pid,addr,value);
    if( ret == -1){
        LOGE("PokeText: %s",strerror(errno));        
        return -1;
    }
    return ret;
}

void PtraceUtil::DumpHex(unsigned int addr,int size)
{
    unsigned char *buf = (unsigned char *)malloc(size);
    if(ReadProcessMemory(addr,buf,size)){
        logger.logHex(buf,size);
    }
    free(buf);
}

int PtraceUtil::GetRegs(pt_regs *reg)
{
    long ret = ptrace(PTRACE_GETREGS, pid, 0,reg );
    if( ret == -1){
        //perror("ptrace PTRACE_GETREGS");
        LOGE("GetRegs Errorno = %d\n",errno);
        return -1;
    }
    return ret;
}

int PtraceUtil::SetRegs(pt_regs *reg)
{
    long ret = ptrace( PTRACE_SETREGS, pid, 0,reg );
    if( ret == -1){
        //perror("ptrace PTRACE_SETREGS");
        LOGE("SetRegs Errorno = %d\n",errno);
        return -1;
    }
    return ret;
}

unsigned int PtraceUtil::GetReturnValue(pt_regs *regs)
{
     return regs->eax;    
}
unsigned int PtraceUtil::GetIP(pt_regs *regs)
{
     return regs->eip;    
}



int PtraceUtil::waitForStop()
{
    LOGD("waitForStop %d",pid);
    while(true){
        int wstatus = 0;
        int ret = waitpid( pid, &wstatus, __WALL );
        LOGD("waitForStop pid=%d ret=%d status=%08X\n",pid, ret,wstatus);
        if(WIFSTOPPED(wstatus)){
            LOGD("WIFSTOPPED");
            break;
        }
        //if(WIFCONTINUED(wstatus)){
        //    printf("WIFCONTINUED\n");
        //    continue;
        //}
        if(WSTOPSIG(wstatus)){
            LOGD("WSTOPSIG");
            continue;
        }
        if(WTERMSIG(wstatus)){
            LOGD("WTERMSIG");
            continue;
        }
        if(WIFSIGNALED(wstatus)){
            LOGD("WIFSIGNALED");
            continue;
        }
        if(WEXITSTATUS(wstatus)){
            LOGD("WEXITSTATUS");
            continue;
        }
        if(WIFEXITED(wstatus)){
            LOGD("WIFEXITED");
            return -1;
        }
    }
    return 0;
}

int PtraceUtil::Push(unsigned int value,pt_regs *regs)
{
    regs->esp -= sizeof(value);   
    WriteProcessMemory((unsigned int) regs->esp, (unsigned char *)&value, sizeof(value));
    return 0;
}

void PtraceUtil::ShowRegs()
{
    pt_regs regs;
    pt_regs* reg;
    GetRegs(&regs);
    reg = &regs;
    printf("ebx\t%08lX\n",reg->ebx);
    printf("ecx\t%08lX\n",reg->ecx);
    printf("edx\t%08lX\n",reg->edx);
    printf("esi\t%08lX\n",reg->esi);
    printf("ebp\t%08lX\n",reg->ebp);
    printf("eax\t%08lX\n",reg->eax);
    printf("xds\t%08X\n",reg->xds);
    
    printf("xes\t%08X\n",reg->xes);
    printf("xfs\t%08X\n",reg->xfs);
    printf("xgs\t%08X\n",reg->xgs);
    printf("orig_eax\t%08lX\n",reg->orig_eax);
    printf("eip\t%08lX\n",reg->eip);
    printf("xcs\t%08X\n",reg->xcs);
    printf("eflags\t%08lX\n",reg->eflags);
    printf("esp\t%08lX\n",reg->esp);
    printf("xss\t%08X\n",reg->xss);
}

long PtraceUtil::Call(uint32_t addr, long *params, uint32_t num_params,  struct pt_regs *regs)
{    
    regs->esp -= (num_params) * sizeof(long) ;  
   // 将mmap函数参数写到stack上 
    WriteProcessMemory((unsigned int) regs->esp, (unsigned char *)params, (num_params) * sizeof(long));
    //ptrace_writedata(pid, (void *)regs->esp, (uint8_t *)params, (num_params) * sizeof(long));    
    
    long tmp_addr = 0x00;    
    regs->esp -= sizeof(long);   
    /**
    push mmap所需要的参数
    push tmp_addr
    */ 
    WriteProcessMemory((unsigned int) regs->esp, (unsigned char *)&tmp_addr, sizeof(tmp_addr));
    //ptrace_writedata(pid, regs->esp, (char *)&tmp_addr, sizeof(tmp_addr));     
    
    //eip指向mmap
    regs->eip = addr;    
    

    //让被调试进程继续运行
    if (SetRegs(regs) == -1     
            || Continue() == -1) {    
        //printf("error\n");    
        return -1;    
    }    
    
    int stat = 0;  
    waitpid(pid, &stat, WUNTRACED);  
    
    while (stat != 0xb7f) {  
        if (Continue() == -1) {  
            //printf("error\n");  
            return -1;  
        }  
        waitpid(pid, &stat, WUNTRACED);  
    }  
    return 0;    
}    




