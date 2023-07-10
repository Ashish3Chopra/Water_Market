clear variables; clc; clf; close all
format long

% Mysore
% QP QR QM QS
filepath = '/Users/ashish/OneDrive - Indian Institute of Science/MAC/Documents/MATLAB/Agri_Benefit_Model/Agri_Benefit_Model_with_Reduced_WA_10%/';
filename = 'Mysore_Agri_PUB_with_Redu_WA_10per.xlsx';
delete([filepath filename])
% Mysore trial without contigency plan and area with tolerance limit and
% with losses i.e area is update considering all these variable
% not we are considering talkul level and water availability changed due to
% this hence re do the PUB calucltion. 
%f = [-1.3559 -4.088 -5.2339 -9.9833];
f =[-9.96558014	-24.35551914 -23.83918457 -9.983310114];
Aeq = []; beq = []; lb = [0 0 0 0]; ub = [];
A = [1 1 1 1
     1.6 4.444 3.333 1
     -1 2.574901561*2.777*0.95 0 0
     1 -2.574901561*2.777*1.05 0 0
     -1 0 3.075073777*2.083*.95 0 
     1 0 -3.075073777*2.083*1.05 0
     -1 0 0 12.74068839*0.625*.95 
     1 0 0 -12.74068839*0.625*1.05
      0 -1 1.194249063*.75*.95 0 
      0  1 -1.194249063*.75*1.05 0 
      0 -1 0 4.948029307*.225*.95 
      0 1 0 -4.948029307*.225*1.05 
      0  0      -1     4.14321389*.3*.95
        0  0    1      -4.14321389*.3*1.05
     ];

%TWA = 709992862.9;
%Basic Status Quo Allocation
%TWA = 1238267374;
TWA = 1114440637;
WA = []; xsol = []; fvalue = [];
pstvlmt = 2000; ngtvlmt = 1114
for i = [0:pstvlmt -1:-1:-ngtvlmt]
    i
    WA = [WA TWA+1000000*i];
    b = [TWA+1000000*i 104548.0716*20000 0 0 0 0  0 0 0 0 0 0  0 0];
    [x, fval] = linprog(f,A,b,Aeq,beq,lb,ub);
    xsol = [xsol x];
    fvalue = [fvalue -fval];
    if i==0
        zeroind = length(fvalue);
    end
end
Qtotal = sum(xsol);
EW = WA - Qtotal;
EW_max = max(EW)
EW_min = min(EW)
Surplus(2:pstvlmt+1) = fvalue(2:pstvlmt+1)-fvalue(1:pstvlmt); %(i= 1 to 2000) - (i= 0 to 1999)
Surplus(1) = fvalue(1)-fvalue(1); %(i= 0) - (i= 0)
Surplus(pstvlmt+2) = fvalue(1) - fvalue(pstvlmt+2); %(i= 0) - (i= -1)
Surplus(pstvlmt+3:pstvlmt+ngtvlmt+1) = fvalue(pstvlmt+2:pstvlmt+ngtvlmt) - fvalue(pstvlmt+3:pstvlmt+ngtvlmt+1); %(i= -1 to -142) - (i= -2 to -143)
AreaP = xsol(1,:)/12500;
AreaR = xsol(2,:)/4500;
AreaM = xsol(3,:)/6000;
AreaS = xsol(4,:)/20000;
AreaTotal = AreaP+AreaR+AreaM+AreaS;
PerCentTAA = (AreaTotal/104548.0716)*100;
PUB = Surplus/1000000;
PUB(zeroind) = 0;
Iteration = [0:pstvlmt -1:-1:-ngtvlmt];

excel_message = {'TWA'; ''; 'QP'; 'QR'; 'QM'; 'QS'; 'Qtotal'; 'EW'; '';...
    'Agri Bene'; ''; 'Surplus Bene'; ''; 'AP'; 'AR'; 'AM'; 'AS';...
    'Total Area'; '% of TAA'; ''; 'PUB'; ''; 'Iteration'};
excel_TWA = num2cell(WA);
excel_Q = num2cell(xsol);
excel_Qtotal = num2cell(Qtotal);
excel_Benefit = num2cell(fvalue);
excel_EW = num2cell(EW);
excel_Surplus = num2cell(Surplus);
excel_AreaP = num2cell(AreaP);
excel_AreaR = num2cell(AreaR);
excel_AreaM = num2cell(AreaM);
excel_AreaS = num2cell(AreaS);
excel_AreaTotal = num2cell(AreaTotal);
excel_PerCentTAA = num2cell(PerCentTAA);
excel_PUB = num2cell(PUB);
excel_Iteration = num2cell(Iteration);

writecell(excel_message, [filepath filename],'Range','A1:A21')
writecell(excel_TWA, [filepath filename],'Range','B1')
writecell(excel_Q, [filepath filename],'Range','B3')
writecell(excel_Qtotal, [filepath filename],'Range','B7')
writecell(excel_EW, [filepath filename],'Range','B8')
writecell(excel_Benefit, [filepath filename],'Range','B10')
writecell(excel_Surplus, [filepath filename],'Range','B12')
writecell(excel_AreaP, [filepath filename],'Range','B14')
writecell(excel_AreaR, [filepath filename],'Range','B15')
writecell(excel_AreaM, [filepath filename],'Range','B16')
writecell(excel_AreaS, [filepath filename],'Range','B17')
writecell(excel_AreaTotal, [filepath filename],'Range','B18')
writecell(excel_PerCentTAA, [filepath filename],'Range','B19')
writecell(excel_PUB, [filepath filename],'Range','B21')
writecell(excel_Iteration, [filepath filename],'Range','B23')

writematrix('Mysore', [filepath 'PUB_ord_WA_10%_Red.xlsx'],'Range','A4')
writecell(excel_PUB, [filepath 'PUB_ord_WA_10%_Red.xlsx'],'Range','B4')
writematrix('Mysore', [filepath 'Benefit_ord_WA_10%_Red.xlsx'],'Range','A4')
writecell(excel_Benefit, [filepath 'Benefit_ord_WA_10%_Red.xlsx'],'Range','B4')