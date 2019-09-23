/*

// Felix Andrews's excellent solution
//
// http://www.mail-archive.com/r-devel@r-project.org/msg14827.html

R CMD SHLIB -o danter_interrupt.so danter_interrupt.c
R --no-restore

dyn.load("rgtk2extras_interrupt.so")
library(RGtk2)
w = gtkWindowNew()
b = gtkButtonNewWithLabel("what")
w$add(b) 

gSignalConnect(b, "clicked", function(...) .C("rgtk2extras_interrupt"))

while(TRUE) Sys.sleep(0.5)

*/

#include <signal.h>  

#ifdef WIN32
extern int UserBreak;
#endif

void rgtk2extras_interrupt(void)
{
#ifdef WIN32
    UserBreak = 1;
    //raise(SIGBREAK);
#else
    raise(SIGINT);
#endif
}
