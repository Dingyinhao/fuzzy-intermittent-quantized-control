function  syn1_1
Tmax=2;h=0.02/3;
m=Tmax/h;    
N=9;      
S=zeros(3*N+3,m+1); 
V=zeros(3*N+3,m+1);
y=zeros(3*N+3,m+1);      
e=zeros(3*N+3,m+1);
z=zeros(3*N+3,m+1);
coup1=zeros(N,1);coup2=zeros(N,1);coup3=zeros(N,1);      
A=[0.1 0.2 0;
  -0.3 0.1 0;
  -0.1 0 0.2];
format rat
D=inv(A);
C=[-1    0    0;
    0   -1    0;
    0    0   -1];
B=[1.25 -3.2 -3.2;
   -3.2  1.1 -4.4;
   -3.2, 4.4  1 ];
c1=0.1;    
c2=0.2;  
G=[-2  1   0    0    0    1    0   0   0     
   1  -3   1    0    0    0    1   0   0    
   0   1  -3    1    0    0    0   0   1      
   0   0   1   -5    1    0    1   1   1  
   0   0   0    1   -3    1    0   1   0    
   1   0   0    0    1   -4    1   1   0   
   0   1   0    1    0    1   -4   0   1  
   0   0   0    1    1    1    0  -3   0  
   0   0   1    1    0    0    1   0  -3];
g='0.5*(abs(x+1)-abs(x-1))';
g=inline(g);
f='0.5*(abs(x+1)-abs(x-1))';
f=inline(f);
R1='0.4+0.2*sin(x)^2';
R1=inline(R1);
R2='0.4+0.2*cos(x)^2';
R2=inline(R2);
r='(abs(x+0.01)-abs(x-0.01))/0.1';  
r=inline(r);
%%%-----控制参数----------------------------------
belta=0.6;
miu1=9.5;      
miu2=10;      
alpha1=15.5;     
alpha2=13    
rho=0.7;
delta=(1-rho)/(1+rho);
%%%-----系统参数----------------------------------
a=[miu1;miu2];
miu=min(min(a))       
b=[alpha1;alpha2];
alpha=min(min(b))  
w2=miu*(1-delta)^(1-belta)
w3=alpha*(1-delta)^(1+belta)*(3*N)^(-belta/2)
L1=1;
L2=1;
Q1=sqrt(max(eig(A'*A)))*L1/min(eig(A'*A))
Q2=sqrt(max(eig(A'*A)))*L2/min(eig(A'*A))
c=kron(sqrt(max(eig(A'*A)))*L1/min(eig(A'*A)),eye(27))+c1*(kron(A,G)+kron(A',G')/2);
rho1=max(eig(c))   
d=kron(sqrt(max(eig(A'*A)))*L2/min(eig(A'*A)),eye(27))+c2*(kron(A,G)+kron(A',G')/2);
rho2=max(eig(d))
e=[rho1;rho2];
w1=max(max(e))                
belta1=4*w2*w3-(w1)^2
%%%-----停息时间---------------------------------- 
T_2=(1/belta)*(2/((belta1)^(1/2)))*((pi/2)+atan(w1/((belta1)^(1/2))))
T=0.8

%%%-----系统初值----------------------------------
          S(3*N+1,1)=1.1;
          S(3*N+2,1)=1;
          S(3*N+3,1)=-0.3;
z0=unifrnd(-10,10,3*N,1);
for q=1:3*N
    y(q,1)=z0(q,1);
end 
for q=1:N
    
   e(3*(q-1)+1,1)=z(3*(q-1)+1,1)-V(3*N+1,1); 
   e(3*(q-1)+2,1)=z(3*(q-1)+2,1)-V(3*N+2,1); 
   e(3*(q-1)+3,1)=z(3*(q-1)+3,1)-V(3*N+3,1); 
   

end
%%%-----同步态----------------------------------
for k=1:m 
     
    S(3*N+1,k+1)=h*(C(1,1)*S(3*N+1,k)+...
                  R1(S(3*N+1,k))*(B(1,1)*g(S(3*N+1,k))+B(1,2)*g(S(3*N+2,k))+B(1,3)*g(S(3*N+3,k)))+...
                  R2(S(3*N+1,k))*(B(1,1)*f(S(3*N+1,k))+B(1,2)*f(S(3*N+2,k))+B(1,3)*f(S(3*N+3,k)))      )+S(3*N+1,k);
     S(3*N+2,k+1)=h*(C(2,2)*S(3*N+2,k)+...
                  R1(S(3*N+2,k))*(B(2,1)*g(S(3*N+1,k))+B(2,2)*g(S(3*N+2,k))+B(2,3)*g(S(3*N+3,k)))+...
                  R2(S(3*N+2,k))*(B(2,1)*f(S(3*N+1,k))+B(2,2)*f(S(3*N+2,k))+B(2,3)*f(S(3*N+3,k)))      )+S(3*N+2,k);
     S(3*N+3,k+1)=h*(C(3,3)*S(3*N+3,k)+...
                  R1(S(3*N+3,k))*(B(3,1)*g(S(3*N+1,k))+B(3,2)*g(S(3*N+2,k))+B(3,3)*g(S(3*N+3,k)))+...
                  R2(S(3*N+3,k))*(B(3,1)*f(S(3*N+1,k))+B(3,2)*f(S(3*N+2,k))+B(3,3)*f(S(3*N+3,k)))      )+S(3*N+3,k);
              
        V(3*N+1,k+1)=A(1,1)*S(3*N+1,k+1)+A(1,2)*S(3*N+2,k+1)+A(1,3)*S(3*N+3,k+1);
        V(3*N+2,k+1)=A(2,1)*S(3*N+1,k+1)+A(2,2)*S(3*N+2,k+1)+A(2,3)*S(3*N+3,k+1);
        V(3*N+3,k+1)=A(3,1)*S(3*N+1,k+1)+A(3,2)*S(3*N+2,k+1)+A(3,3)*S(3*N+3,k+1);
 
 %%%-----控制器----------------------------------   
    for q=1:N
                      
    u(3*(q-1)+1,k)=-((T_2)/T)*miu1*(D(1,1)*r(quantizer(e(3*(q-1)+1,k)))*(abs(quantizer(e(3*(q-1)+1,k))))^(1-belta)+D(1,2)*r(quantizer(e(3*(q-1)+2,k)))*(abs(quantizer(e(3*(q-1)+2,k))))^(1-belta)+...
                     D(1,3)*r(quantizer(e(3*(q-1)+3,k)))*(abs(quantizer(e(3*(q-1)+3,k))))^(1-belta))-...
                    ((T_2)/T)*alpha1*(D(1,1)*r(quantizer(e(3*(q-1)+1,k)))*(abs(quantizer(e(3*(q-1)+1,k))))^(1+belta)+D(1,2)*r(quantizer(e(3*(q-1)+2,k)))*(abs(quantizer(e(3*(q-1)+2,k))))^(1+belta)+...
                     D(1,3)*r(quantizer(e(3*(q-1)+3,k)))*(abs(quantizer(e(3*(q-1)+3,k))))^(1+belta));  
    u(3*(q-1)+2,k)=-((T_2)/T)*miu1*(D(2,1)*r(quantizer(e(3*(q-1)+1,k)))*(abs(quantizer(e(3*(q-1)+1,k))))^(1-belta)+D(2,2)*r(quantizer(e(3*(q-1)+2,k)))*(abs(quantizer(e(3*(q-1)+2,k))))^(1-belta)+...
                    D(2,3)*r(quantizer(e(3*(q-1)+3,k)))*(abs(quantizer(e(3*(q-1)+3,k))))^(1-belta))-...
                    ((T_2)/T)*alpha1*(D(2,1)*r(quantizer(e(3*(q-1)+1,k)))*(abs(quantizer(e(3*(q-1)+1,k))))^(1+belta)+D(2,2)*r(quantizer(e(3*(q-1)+2,k)))*(abs(quantizer(e(3*(q-1)+2,k))))^(1+belta)+...
                    D(2,3)*r(quantizer(e(3*(q-1)+3,k)))*(abs(quantizer(e(3*(q-1)+3,k))))^(1+belta)); 
    u(3*(q-1)+3,k)=-((T_2)/T)*miu1*(D(3,1)*r(quantizer(e(3*(q-1)+1,k)))*(abs(quantizer(e(3*(q-1)+1,k))))^(1-belta)+D(3,2)*r(quantizer(e(3*(q-1)+2,k)))*(abs(quantizer(e(3*(q-1)+2,k))))^(1-belta)+...
                    D(3,3)*r(quantizer(e(3*(q-1)+3,k)))*(abs(quantizer(e(3*(q-1)+3,k))))^(1-belta))-...
                    ((T_2)/T)*alpha1*(D(3,1)*r(quantizer(e(3*(q-1)+1,k)))*(abs(quantizer(e(3*(q-1)+1,k))))^(1+belta)+D(3,2)*r(quantizer(e(3*(q-1)+2,k)))*(abs(quantizer(e(3*(q-1)+2,k))))^(1+belta)+...
                    D(3,3)*r(quantizer(e(3*(q-1)+3,k)))*(abs(quantizer(e(3*(q-1)+3,k))))^(1+belta)); 
    
    v(3*(q-1)+1,k)=-((T_2)/T)*miu2*(D(1,1)*r(quantizer(e(3*(q-1)+1,k)))*(abs(quantizer(e(3*(q-1)+1,k))))^(1-belta)+D(1,2)*r(quantizer(e(3*(q-1)+2,k)))*(abs(quantizer(e(3*(q-1)+2,k))))^(1-belta)+...
                     D(1,3)*r(quantizer(e(3*(q-1)+3,k)))*(abs(quantizer(e(3*(q-1)+3,k))))^(1-belta))-...
                    ((T_2)/T)*alpha2*(D(1,1)*r(quantizer(e(3*(q-1)+1,k)))*(abs(quantizer(e(3*(q-1)+1,k))))^(1+belta)+D(1,2)*r(quantizer(e(3*(q-1)+2,k)))*(abs(quantizer(e(3*(q-1)+2,k))))^(1+belta)+...
                     D(1,3)*r(quantizer(e(3*(q-1)+3,k)))*(abs(quantizer(e(3*(q-1)+3,k))))^(1+belta));  
    v(3*(q-1)+2,k)=-((T_2)/T)*miu2*(D(2,1)*r(quantizer(e(3*(q-1)+1,k)))*(abs(quantizer(e(3*(q-1)+1,k))))^(1-belta)+D(2,2)*r(quantizer(e(3*(q-1)+2,k)))*(abs(quantizer(e(3*(q-1)+2,k))))^(1-belta)+...
                    D(2,3)*r(quantizer(e(3*(q-1)+3,k)))*(abs(quantizer(e(3*(q-1)+3,k))))^(1-belta))-...
                   ((T_2)/T)*alpha2*(D(2,1)*r(quantizer(e(3*(q-1)+1,k)))*(abs(quantizer(e(3*(q-1)+1,k))))^(1+belta)+D(2,2)*r(quantizer(e(3*(q-1)+2,k)))*(abs(quantizer(e(3*(q-1)+2,k))))^(1+belta)+...
                    D(2,3)*r(quantizer(e(3*(q-1)+3,k)))*(abs(quantizer(e(3*(q-1)+3,k))))^(1+belta)); 
    v(3*(q-1)+3,k)=-((T_2)/T)*miu2*(D(3,1)*r(quantizer(e(3*(q-1)+1,k)))*(abs(quantizer(e(3*(q-1)+1,k))))^(1-belta)+D(3,2)*r(quantizer(e(3*(q-1)+2,k)))*(abs(quantizer(e(3*(q-1)+2,k))))^(1-belta)+...
                    D(3,3)*r(quantizer(e(3*(q-1)+3,k)))*(abs(quantizer(e(3*(q-1)+3,k))))^(1-belta))-...
                    ((T_2)/T)*alpha2*(D(3,1)*r(quantizer(e(3*(q-1)+1,k)))*(abs(quantizer(e(3*(q-1)+1,k))))^(1+belta)+D(3,2)*r(quantizer(e(3*(q-1)+2,k)))*(abs(quantizer(e(3*(q-1)+2,k))))^(1+belta)+...
                    D(3,3)*r(quantizer(e(3*(q-1)+3,k)))*(abs(quantizer(e(3*(q-1)+3,k))))^(1+belta));  
       
      for j=1:N
           coup1(j)=G(q,j)*z(3*(j-1)+1,k);        
           coup2(j)=G(q,j)*z(3*(j-1)+2,k); 
           coup3(j)=G(q,j)*z(3*(j-1)+3,k); 
       end 
%%%-----系统----------------------------------   
    y(3*(q-1)+1,k+1)=h*(C(1,1)*y(3*(q-1)+1,k)+...
                  R1(y(3*(q-1)+1,k))*(B(1,1)*g(y(3*(q-1)+1,k))+B(1,2)*g(y(3*(q-1)+2,k))+B(1,3)*g(y(3*(q-1)+3,k)))+...
                  R2(y(3*(q-1)+1,k))*(B(1,1)*f(y(3*(q-1)+1,k))+B(1,2)*f(y(3*(q-1)+2,k))+B(1,3)*f(y(3*(q-1)+3,k)))+...
                  R1(y(3*(q-1)+1,k))*c1*sum(coup1)+...
                  R2(y(3*(q-1)+1,k))*c2*sum(coup1)+...
                  R1(y(3*(q-1)+1,k))*u(3*(q-1)+1,k)+...
                  R2(y(3*(q-1)+1,k))*v(3*(q-1)+1,k)   )+y(3*(q-1)+1,k);
              
    y(3*(q-1)+2,k+1)=h*(C(2,2)*y(3*(q-1)+2,k)+...
                  R1(y(3*(q-1)+2,k))*(B(2,1)*g(y(3*(q-1)+1,k))+B(2,2)*g(y(3*(q-1)+2,k))+B(2,3)*g(y(3*(q-1)+3,k)))+...
                  R2(y(3*(q-1)+2,k))*(B(2,1)*f(y(3*(q-1)+1,k))+B(2,2)*f(y(3*(q-1)+2,k))+B(2,3)*f(y(3*(q-1)+3,k)))+...
                  R1(y(3*(q-1)+2,k))*c1*sum(coup2)+...
                  R2(y(3*(q-1)+2,k))*c2*sum(coup2)+...
                  R1(y(3*(q-1)+2,k))*u(3*(q-1)+2,k)+...
                  R2(y(3*(q-1)+2,k))*v(3*(q-1)+2,k)   )+y(3*(q-1)+2,k);
  
    y(3*(q-1)+3,k+1)=h*(C(3,3)*y(3*(q-1)+3,k)+...
                  R1(y(3*(q-1)+3,k))*(B(3,1)*g(y(3*(q-1)+1,k))+B(3,2)*g(y(3*(q-1)+2,k))+B(3,3)*g(y(3*(q-1)+3,k)))+...
                  R2(y(3*(q-1)+3,k))*(B(3,1)*f(y(3*(q-1)+1,k))+B(3,2)*f(y(3*(q-1)+2,k))+B(3,3)*f(y(3*(q-1)+3,k)))+...
                  R1(y(3*(q-1)+3,k))*c1*sum(coup3)+...
                  R2(y(3*(q-1)+3,k))*c2*sum(coup3)+...
                  R1(y(3*(q-1)+3,k))*u(3*(q-1)+3,k)+...
                  R2(y(3*(q-1)+3,k))*v(3*(q-1)+3,k)   )+y(3*(q-1)+3,k);
 
 
              
        z(3*(q-1)+1,k+1)=A(1,1)*y(3*(q-1)+1,k+1)+A(1,2)*y(3*(q-1)+2,k+1)+A(1,3)*y(3*(q-1)+3,k+1);
        z(3*(q-1)+2,k+1)=A(2,1)*y(3*(q-1)+1,k+1)+A(2,2)*y(3*(q-1)+2,k+1)+A(2,3)*y(3*(q-1)+3,k+1);
        z(3*(q-1)+3,k+1)=A(3,1)*y(3*(q-1)+1,k+1)+A(3,2)*y(3*(q-1)+2,k+1)+A(3,3)*y(3*(q-1)+3,k+1);
        
    %%%-----输出误差---------------------------------- 
  
    e(3*(q-1)+1,k+1)=z(3*(q-1)+1,k+1)-V(3*N+1,k+1); 
    e(3*(q-1)+2,k+1)=z(3*(q-1)+2,k+1)-V(3*N+2,k+1); 
    e(3*(q-1)+3,k+1)=z(3*(q-1)+3,k+1)-V(3*N+3,k+1); 
    
 
    end
end
 
t=linspace(0,Tmax,m);
  figure(1);
  for q=1:N
   plot(t,u(3*(q-1)+1,:),'m-','LineWidth',0.7)
  hold on
  plot(t,u(3*(q-1)+2,:),'k-','LineWidth',0.7)
  hold on
   plot(t,u(3*(q-1)+3,:),'c-','LineWidth',0.7)
  hold on
    plot(t,v(3*(q-1)+1,:),'g-','LineWidth',0.7)
  hold on
  plot(t,v(3*(q-1)+2,:),'r-','LineWidth',0.7)
  hold on
   plot(t,v(3*(q-1)+3,:),'b-','LineWidth',0.7)
  hold on
  leg1=xlabel('$t$')
  leg2=ylabel('$u_{{\imath}1}(t), u_{{\imath}2}(t), q=1,2,...,9$')    
  leg3=legend('$u^1_{{\imath}1}(t)$','$u^2_{{\imath}1}(t)$','$u^3_{{\imath}1}(t)$','$u^1_{{\imath}2}(t)$','$u^2_{{\imath}2}(t)$','$u^3_{{\imath}2}(t)$');
  set(leg1,'Interpreter','latex');
  set(leg2,'Interpreter','latex');
  set(leg3,'Interpreter','latex');
  end
 t=linspace(0,Tmax,m+1); 
 
figure(2);
for q=1:N
  plot(t,e(3*(q-1)+1,:),'r-','LineWidth',0.7)
  hold on
  plot(t,e(3*(q-1)+2,:),'b-','LineWidth',0.7)
  hold on
  plot(t,e(3*(q-1)+3,:),'g-','LineWidth',0.7) 
  hold on
  plot(T,0,'.r','MarkerSize',20)
  hold on
  leg1=xlabel('$t$')
  leg2=ylabel('$\mathcal{E}_{\imath}(t), {\imath}=1,2,...,9$')    
  leg3=legend('$\mathcal{E}^1_{\imath}(t)$','$\mathcal{E}^2_{\imath}(t)$','$\mathcal{E}^3_{\imath}(t)$','$T_{\mathrm{pat}}=0.8$');
  set(leg1,'Interpreter','latex');
  set(leg2,'Interpreter','latex');
  set(leg3,'Interpreter','latex');
end

