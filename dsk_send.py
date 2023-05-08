import sys
import serial
import time

def GetBin(src_name,dst_file):
    print("\n")
    print("DSK file : "+src_name)
    print("\n")
    print("HEX data from DSK file will be save to : "+dst_file)
    print("\n")

    src = open(src_name,'r')
    dst = open(dst_file,"w+")
    tmp = open('tmp.txt',"w+")
    tmp2 = open('tmp2.txt',"w+")
    
    lines = src.readlines()
    data_len = (int)(len(lines))

    l = list(lines)
    del(l[data_len - 1])
    del(l[data_len - 2])
    del(l[0])
    del(l[0])
    del(l[0])
    lines = "".join(l)
    tmp.write(lines)     
    tmp.close()
    tmp = open('tmp.txt',"r")

    while(True):
        str_tmp = tmp.readline()
        data_len = (int)(len(str_tmp))
        if not str_tmp:
            break  

        l = list(str_tmp)
        del(l[0])

        if l[4]!='7':
            del(l[4])

            if l[8]!='7':       
                del(l[8])
 
                if l[12]!='7':            
                    del(l[12])

                    if l[16]!='7': 
                        del(l[16])
 
                        if l[20]!='7':        
                            del(l[20])
 
                            if l[24]!='7':
                                del(l[24])
  
                                if l[28]!='7':
                                   del(l[28])

                                   if l[32]!='7':    
                                      del(l[32])
       
        str_tmp = "".join(l)
        tmp2.write(str_tmp)
        
    tmp2.close()    

    a = 0 
    tmp2 = open('tmp2.txt',"r+")
    data_len_2 = 0
    while(True):
        str_file = tmp2.readline()
        data_len = (int)(len(str_file))  

        a=a+1

        if not str_file:
            break

        str_file = str_file[4:(data_len-7)]
        print('line',a,'=',str_file)
        data_len_2 = data_len_2 + (int)(len(str_file))
        list_file = list(str_file)
        for i in range(1,((data_len-11)-1)//2+1):
            list_file.insert(2*i+(i-1)," ")
        str_file = ''.join(list_file)
        dst.write(str_file)
        dst.write('\n')

    src.close()
    dst.close()

    data_len_3 = (int)(data_len_2/2)  
    word_len = int((data_len_3/2)-1)
    if (word_len+1) > 512:
        print("\n")
        print('!!! Error !!! Program length =',word_len+1,'words. Only 512 words available.')
    if (word_len+1) < 513:
        ser = serial.Serial(
            port='COM6',
            baudrate=38400,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_TWO,
            bytesize=serial.EIGHTBITS
        )
        print("\n")
        print('COM6 Open =',ser.isOpen())
        time.sleep(0.01)
        ser.dtr = 1
        time.sleep(0.01)
        ser.dtr = 0
        time.sleep(0.01)
        ser.write(bytes.fromhex('80'))
        time.sleep(0.05)   
        src = open(dst_file,'r')
        ser.write(bytes.fromhex('03')) # - write command
        time.sleep(0.01) #                                     
        ser.write(bytes.fromhex('FE')) # -\ 
        time.sleep(0.01) #                 \ _ write adress
        ser.write(bytes.fromhex('00')) # -/
        time.sleep(0.01)
        print("\n")
        print('send',(data_len_3),'bytes (',word_len+1,'words )')
        print("\n")
        word_len_16 = int(word_len >> 8)
        ser.write(int.to_bytes(word_len_16, 1, "big")) # -\ 
        time.sleep(0.01) #                                 \ _ n words to send (n*2 bytes)
        word_len_0 = int(word_len & 255) #                 /
        ser.write(int.to_bytes(word_len_0, 1, "big"))  # -/ 
        time.sleep(0.01)
        
        while(True):
            line = src.readline()
            if not line:
                break    
            i=0
            while(True):
                Hex_str = bytes.fromhex(line)
                data_len = (int)(len(Hex_str))
                i=i+1 
                if data_len < i:
                    break
                print(hex(Hex_str[i-1]), end=' ', flush=True)
                ser_data = Hex_str[i-1]
                ser.write(int.to_bytes(ser_data, 1, "big"))
                time.sleep(0.01)       
                
        src.close()
        print("\n")
        print('Program sent.')  
        ser.write(bytes.fromhex('05')) # - RUN command
        time.sleep(0.01)
        ser.write(bytes.fromhex('FE')) #  -\ _ RUN adress
        time.sleep(0.01) #                 /
        ser.write(bytes.fromhex('00')) # -/
        time.sleep(0.01)
        ser.write(bytes.fromhex('80')) 

      
def main():
    src_filename = sys.argv[1]
    dst_filename = sys.argv[2]

    GetBin(src_filename,dst_filename)

if __name__ == "__main__":
    if(len(sys.argv) != 3):
        print("\n")
        print("!!! Error !!!\n")
        print("python dsk_send.py <name>.DSK <name>.hex.txt\r\n")
        exit()
    main()