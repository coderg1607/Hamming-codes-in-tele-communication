clear all;

clc;
fprintf("WELL COME THIS SC206 PROJECT-2020\n\n*****AUTHER:GAUTAM DHANSUKHBHAI AJUGIYA(201901134)*****\n*****COLLEGE:DHIRUBHAI AMBANI INSTITUTE OF ICT-GANDHINAGAR****\n\n");
fprintf("---TOPIC:HAMMING CODES IN TELICOMMUNICATIONS CHANNEL---\n\n");

SIZE_OF_INPUT=input("ENTER NUMBER OF BITS(EACH BITS CONTAIS 4 MESSAGE )");

INPUT_MESSAGE=zeros(1,SIZE_OF_INPUT*4);

%RANDOM MESSAGE GENERATOR

for i=1:SIZE_OF_INPUT*4
    
    INPUT_MESSAGE(i)=randi(2,1)-1;
    
    
end

fprintf("THIS IS YOUR RANDOMLY GENERATED MESSAGE:\n");
disp(INPUT_MESSAGE);

%HERE WE CREATE "GENERATOR MATRIX" TO ENCODE OUR MESSAGE BITS

GENERATOR_MATRIX=[1 1 0 1 0 0 1;0 1 0 1 0 1 0;1 0 0 1 1 0 0;1 1 1 0 0 0 0];

% -->  1 1 0 1 0 0 1
% -->  0 1 0 1 0 1 0
% -->  1 0 0 1 1 0 0
% -->  1 1 1 0 0 0 0
%---->FORMATE OF ENCODED MESSAGE BIT [P1 P2 M1 P3 M2 M3 M4]
%****>P1=M1 + M2 + M4
%****>P2=M1 + M3 + M4
%****>P3=M2 + M3 + M4


 TEMP_ARRAY1=zeros(SIZE_OF_INPUT,4);
 t="";
 k=0;
 
 %MAINLY THIS SECTION IS CREATED TO HANDLE MORE THAN 1 BITS
 
 for i=1:SIZE_OF_INPUT
   
     for j=1:4
         
         k=k+1;
         TEMP_ARRAY1(i,j)=INPUT_MESSAGE(k);
         
     end
end
 
%SECTION WISE OUTPUT

fprintf("THIS IS SECTION WISE OUTPUT OF HAMMING ENCODER\nFORMATE:[ P1 P2 M1 P3 M2 M3 M4 ]\n\n\n");

for(j=1:SIZE_OF_INPUT)
    
    fprintf("ENCODED MESSAGE %d:",j)
    disp(mod(TEMP_ARRAY1(j,:)*GENERATOR_MATRIX,2)); % ENCODED MESSAGE=(MESSAGE MATRIX)*(GENERATOR MATRIX)
   t=t +"  "+ int2str(mod(TEMP_ARRAY1(j,:)*GENERATOR_MATRIX,2));%HERE WE ARE CONVERTING 2D ARRAY INTO 1D ARRAY
   
end
INPUT_F0R_CHANNEL = str2num(t);

fprintf("LINEAR OUTPUT OF THE MESSAGE BITS:\n");

disp(INPUT_F0R_CHANNEL);

i = length(INPUT_F0R_CHANNEL);

%%starting of channel coding

fprintf("\n<1>BINARY SYMMETRIC CHANNEL\n<2>BINARY ERASER CHANNEL\n<3>GAUSSIAN CHANNEL\n");
C=input("\nNOW IT'S YOUR TURN ...CHOSE A CHANNEL FOR YOUR MESSAGE TRANSMISSION");

%CODING OF BSC CHANNEL
%if rand function's value go beyond than pro_err than error(bit flip) occur...
%if error event occure than 1 become 0 and 0 become 1...
 
if(C==1)
    BSC=INPUT_F0R_CHANNEL;
    pro_err=0.1;
    for n=1:i
        err_event=rand()<pro_err;
        if(err_event)
            if(INPUT_F0R_CHANNEL(n)==1)
                BSC(n)=0;
            else
                BSC(n)=1;
                end
        end
    end
    fprintf("OUTPUT FROM BSC CHANNEL IS:\n");
    disp(BSC);
   OUTPUT_FOR_DECODER=BSC;
    
elseif(C==2)
    
 %CODING OF BEC CHANNEL
%in this channel if error event occure than n th bit will  be erased
%here NaN represents the erased bit

     BEC=INPUT_F0R_CHANNEL;
      pro_err=0.1;
     for n=1:i
     err_event=rand()<pro_err;
            if(err_event)       
            if(INPUT_F0R_CHANNEL(n)==1)
                BEC(n)=404;
            end
            end
         end
   fprintf("OUTPUT FROM BEC CHANNEL IS:\n");
  disp(BEC);
  OUTPUT_FOR_DECODER=BEC;
  
else 
    
 %CODING OF GAUSSIAN NOISE CHANNEL
 %THIS CHANNEL REAPRESENTS THE REAL  WORLD TELECOMMUNICATION CHANNEL
 
    inp_chan=INPUT_F0R_CHANNEL;
    r=1/2; %%rate
    rDecision_bound=0;
    %next step convert 0 to -1
    
    Gaussian_out=inp_chan*2-1;
    k=1;
    %mathematical calculation
    
    for EbNodB=0:0.5:(i-1)/2
        EbNolin=10^(EbNodB/10);
        sigma2=1/(2*r*EbNolin);
        sigma=sqrt(sigma2);
        N=sigma*randn;
        Gaussian_out(k)=inp_chan(k)+N;
        for j=1:i
            if(Gaussian_out(j)>rDecision_bound)
                Gaussian_out(j)=1;
            else
                Gaussian_out(j)=-1;
            end
        end
        k=k+1;
    end
    Gaussian_out(Gaussian_out == -1)= 0;
    fprintf("OUTPUT FROM GAUSSIAN CHANNEL IS: \n");
    disp(Gaussian_out);
    OUTPUT_FOR_DECODER=Gaussian_out;
    
end   

%IF WE GET ERROR IN BEC THEN FOLLOWING CODE WILL BE EXECUTED

if(C==2)
    for i=1:SIZE_OF_INPUT*7
        if(OUTPUT_FOR_DECODER(i)==404)
            
            if(INPUT_F0R_CHANNEL(i)==0)
                OUTPUT_FOR_DECODER(i)=1;
            else
                OUTPUT_FOR_DECODER(i)=0;
            end
            
        end
    end
end

%%DECODING PART

if(C<=3)
PARITY_CHECK_MATRIX=[1 0 1 0 1 0 1;0 1 1 0 0 1 1;0 0 0 1 1 1 1];

%---> 1 0 1 0 1 0 1
%---> 0 1 1 0 0 1 1
%---> 0 0 0 1 1 1 1

TEMP_ARRAY2=zeros(SIZE_OF_INPUT,7);

k=0;
 
 %MAINLY THIS SECTION IS CREATED TO HANDLE MORE THAN 1 BITS
 
 for i=1:SIZE_OF_INPUT
   
     for j=1:7
         
         k=k+1;
         TEMP_ARRAY2(i,j)=OUTPUT_FOR_DECODER(k);
         
     end
     
     %THIS GIVES YOU PARITY MATRIX
     
     FINAL_OUTPUT=transpose(PARITY_CHECK_MATRIX*(transpose(TEMP_ARRAY2(i,:))));
     
     
     %CONVERTING BINARY LOCATION INTO DECIMAL LOCATION(ERROR DETACTION)
     
     
     p=bi2de(mod(FINAL_OUTPUT,2));
     if(p~=0)
     fprintf("ERROR POINT IS %d",(i-1)*7+p);
     end
     
     %ERROR CORRECTION CODE
     
     if(p>=1)
         if(OUTPUT_FOR_DECODER((i-1)*7+p)==0)
            OUTPUT_FOR_DECODER((i-1)*7+p)=1;
         else
             OUTPUT_FOR_DECODER((i-1)*7+p)=0;
         end
     else
     end
    
 end
 
 %OUTPUT WITHOUT PARITY BIT
 
  DRCODING_MATRIX=[0 0 0 0 0 0 1;0 0 0 0 0 1 0;0 0 0 0 1 0 0;0 0 1 0 0 0 0];
  TEMP_ARRAY3=zeros(SIZE_OF_INPUT,4);
  k=0;
  STR=" ";
  for i=1:SIZE_OF_INPUT
   
     for j=1:7
         
         k=k+1;
         TEMP_ARRAY3(i,j)=OUTPUT_FOR_DECODER(k);
         
     end
     STR=STR + " "+int2str(transpose(DRCODING_MATRIX*(transpose(TEMP_ARRAY3(i,:)))));
     
      
 end
  

 OUTPUT=str2num(STR);
end


 %CODING FOR OUTPUT
 if(C==1)
     fprintf("HEY!!!\nI REACIVERD THE MESSAGE FROM BSC CHANNEL\nI TRIED TO GIVE YOU ACCURATE OUTPOT WITHOUT ANY ERROR\nPLEASE SIR COMPARE IT WITH YOUR ENCODED MESSAGE\n");
     fprintf("OUTPUT WITH PARITY BITS..\n");
     
     disp(OUTPUT_FOR_DECODER);
     fprintf("OUTPUT WITHOUT PARITY BITS..\n");
     disp(OUTPUT);
 elseif(C==2)
     fprintf("HEY!!!\nI REACIVERD THE MESSAGE FROM BEC CHANNEL\nI TRIED TO GIVE YOU ACCURATE OUTPOT WITHOUT ANY ERROR\nPLEASE SIR COMPARE IT WITH YOUR ENCODED MESSAGE\n");
     fprintf("OUTPUT WITH PARITY BITS..\n")
     disp(OUTPUT_FOR_DECODER);
     fprintf("OUTPUT WITHOUT PARITY BITS..\n")
      disp(OUTPUT);
 elseif(C==3)
     fprintf("HEY!!!\nI REACIVERD THE MESSAGE FROM GAUSSIAN  CHANNEL\nI TRIED TO GIVE YOU ACCURATE OUTPOT WITHOUT ANY ERROR\nPLEASE SIR COMPARE IT WITH YOUR ENCODED MESSAGE\n");
     fprintf("OUTPUT WITH PARITY BITS..\n")
     disp(OUTPUT_FOR_DECODER);
     fprintf("OUTPUT WITHOUT PARITY BITS..\n")
      disp(OUTPUT);
 else
     fprintf("***INVALID CHOICE****");
 end
 
 
 fprintf("THANK YOU FOR USING THIS SOFTWARE PRODUCT CODE\nDEVLOPER:GAUTAM D. AJUGIYA");
 
