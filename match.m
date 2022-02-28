function op = match(Im1,Im2)
%Loading images.
tic;

% gray1=rgb2gray(Im1);
% gray2=rgb2gray(Im2);
single1=single(Im1);
single2=single(Im2);
%SIFT features.
[f1,d1]=vl_sift(single1);
[f2,d2]=vl_sift(single2);
%Matching Features.

[matches, ~] = vl_ubcmatch(d1,d2);

% Making vector p1=X1 in homogenous form.

X1=f1(1:2,matches(1,:));
X1=[X1;ones(1,size(matches,2))];


% Making vector p2=X2 in homogenous form.

X2=f2(1:2,matches(2,:));
X2=[X2;ones(1,size(matches,2))];


Iteration=50;
threshold=2;
ncol=4;
prevscore=0;

%Calculating parameters for transformation..
x1_bar=sum(X1(1,:))/size(matches,2);
y1_bar=sum(X1(2,:))/size(matches,2);
x2_bar=sum(X2(1,:))/size(matches,2);
y2_bar=sum(X2(2,:))/size(matches,2);
% (x-x_bar) , (y-y_bar) 
Y1=[X1(1,:)-x1_bar;X1(2,:)-y1_bar];
Y2=[X2(1,:)-x2_bar;X2(2,:)-y2_bar];

C1=(sum((Y1(1,:).^2+Y1(2,:).^2).^(1/2)))/size(matches,2);
C2=(sum((Y2(1,:).^2+Y2(2,:).^2).^(1/2)))/size(matches,2);

% Transformation matrix T1 = T11*T21 , T2 = T11'*T21' (i.e for p2)

T1=[sqrt(2)/C1,0,-(sqrt(2)/C1)*x1_bar;0,sqrt(2)/C1,-(sqrt(2)/C1)*y1_bar;0,0,1];
T2=[sqrt(2)/C2,0,-(sqrt(2)/C2)*x2_bar;0,sqrt(2)/C2,-(sqrt(2)/C2)*y2_bar;0,0,1];
%Z1=T1*p1,Z2=T2*p2
Z1=T1*X1;
Z2=T2*X2;

for i=1:Iteration
    % Taking 4 columns randomly from transformed p2 i.e Z2
    x = randperm(size(matches,2),ncol);
    A = [];
    for j=1:ncol
        Z=[Z1(:,x(j))',zeros(1,3),-Z1(:,x(j))'*Z2(1,x(j));zeros(1,3),Z1(:,x(j))',-Z1(:,x(j))'*Z2(2,x(j))];
        A=[A;Z];
    end
    [S,V,D] = svd(A);

     H=D(:,9);
     H=reshape(H,3,3)';
     H_=inv(T2)*H*T1;
     p2=H_*X1;
     p2(1,:)=p2(1,:)./p2(3,:);
     p2(2,:)=p2(2,:)./p2(3,:);
     p2(3,:)=p2(3,:)./p2(3,:);
     %Calculating error
     err=X2-p2;
     n = vecnorm(err);
     score = sum( n<threshold);
     if score>prevscore
         prevscore=score;
         True_H=H_;
     end    
end

True_H=True_H./True_H(3,3);
op=True_H;
    




    
    




