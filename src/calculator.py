import serial
import sys

num=input()
ser=serial.Serial('com'+num,9600)
ser.parity=serial.PARITY_EVEN
ser.stopbits=2

def send(stri):
    global ser
    stri=list(map(eval,stri))
    data=[stri[0]*16+stri[1],stri[2]*16+stri[3],0xff]
    ser.write(data)

try:
    ser.open()
except:
    pass
arg=[]
#global write
write=['0','0','0','0']
while(True):
    tmp=chr(ord(ser.read(1)))
    if(tmp=='\0'):
        del(arg[-1])
        sys.stdout.write('\b \b')
        sys.stdout.flush()
    elif(tmp=='='):
        if(len(arg)!=0):
            #global write
            workout=eval(''.join(arg))
            write=list(format(int(workout)%10000,'04d'))
            send(write)
            arg=[]
            sys.stdout.write('=\n'+str(workout)+'\n')
            sys.stdout.flush()
        else:
            #global write
            send(write)
    else:
        arg.append(tmp)
        sys.stdout.write(tmp)
        sys.stdout.flush()
