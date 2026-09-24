function Q=quantizer(tao)
kexi_0=1;
rho=0.7;
j_max=30;
j_min=-3;
delta=(1-rho)/(1+rho);
mathcal=[];
for j=j_max:-1:j_min   %以1为步长从最大值到最小值，每次降1
    mathcal=[mathcal rho^j.*kexi_0];
end
partition=1/(1+delta).*mathcal(2:end);

if  tao==0
    Q=0;
elseif tao > 0
    [~,Q]=quantiz(tao,partition,mathcal);
else  
    [~,Q]=quantiz(-tao,partition,mathcal);
    Q=-Q;
end   