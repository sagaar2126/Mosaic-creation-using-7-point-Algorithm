im1=imread('11.jpg');
im2=imread('22.jpg');
im3=imread('33.jpg');
im4=imread('44.jpg');
im5=imread('55.jpg');

gray1= rgb2gray(im1);
gray2= rgb2gray(im2);
gray3= rgb2gray(im3);
gray4= rgb2gray(im4);
gray5= rgb2gray(im5);

% Calculating homography..
H_12 = match(gray2,gray1);
H_23 = match(gray3,gray2);
H_43 = match(gray3,gray4);
H_54 = match(gray4,gray5);

H_13 = H_12*H_23;
H_53 = H_43*H_54;

% Transforming corners of each non-refernece image to reference image
% co-ordinate system
box31 = [1,size(im1,2),size(im1,2),1 ;1,1,size(im1,1),size(im1,1) ;1,1,1,1 ] ;
box31_ = inv(H_13) * box31 ;
box31_(1,:) = box31_(1,:)./box31_(3,:); box31_(2,:) = box31_(2,:)./box31_(3,:);

box32 = [1,size(im2,2),size(im2,2),1 ;1,1,size(im2,1),size(im2,1) ;1,1,1,1 ] ;
box32_ = inv(H_23) * box32 ;
box32_(1,:) = box32_(1,:)./box32_(3,:); box32_(2,:) = box32_(2,:)./box32_(3,:);

box43 = [1,size(im4,2),size(im4,2),1 ;1,1,size(im4,1),size(im4,1) ;1,1,1,1 ] ;
box43_ = inv(H_43) * box43 ;
box43_(1,:) = box43_(1,:)./box43_(3,:); box43_(2,:) = box43_(2,:)./box43_(3,:);

box53 = [1,size(im5,2),size(im5,2),1 ;1,1,size(im5,1),size(im5,1) ;1,1,1,1 ] ;
box53_ = inv(H_53) * box53 ;
box53_(1,:) = box53_(1,:)./box53_(3,:); box53_(2,:) = box53_(2,:)./box53_(3,:);

% calculating minimum x and y , maximum x and y. 
minx= min([1,min(box31_(1,:)),min(box32_(1,:)),min(box43_(1,:)),min(box53_(1,:))]);
miny= min([1,min(box31_(2,:)),min(box32_(2,:)),min(box43_(2,:)),min(box53_(2,:))]);
maxx= max([1,max(box31_(1,:)),max(box32_(1,:)),max(box43_(1,:)),max(box53_(1,:))]);
maxy= max([1,max(box31_(2,:)),max(box32_(2,:)),max(box43_(2,:)),max(box53_(2,:))]);                 
% Creating fram
u=minx:maxx;
v=miny:maxy;
[u_,v_] = meshgrid(u,v) ;

%Interpolating reference image
im1_ = vl_imwbackward(im2double(im3),u_,v_) ;
  
% Rest of images first transformed then interpolated 
z_13 = H_13(3,1) * u_ + H_13(3,2) * v_ + H_13(3,3) ;
u_13 = (H_13(1,1) * u_ + H_13(1,2) * v_ + H_13(1,3)) ./ z_13 ;
v_13 = (H_13(2,1) * u_+ H_13(2,2) * v_+ H_13(2,3)) ./ z_13;
im2_ = vl_imwbackward(im2double(im1),u_13,v_13) ;

z_23 = H_23(3,1) * u_ + H_23(3,2) * v_+ H_23(3,3) ;
u_23 = (H_23(1,1) * u_ + H_23(1,2) * v_ + H_23(1,3)) ./ z_23 ;
v_23 = (H_23(2,1) * u_+ H_23(2,2) * v_ + H_23(2,3)) ./ z_23;
im3_ = vl_imwbackward(im2double(im2),u_23,v_23) ;

z_43 = H_43(3,1) * u_ + H_43(3,2) * v_ + H_43(3,3) ;
u_43 = (H_43(1,1) * u_ + H_43(1,2) * v_+ H_43(1,3)) ./ z_43 ;
v_43 = (H_43(2,1) * u_ + H_43(2,2) * v_ + H_43(2,3)) ./ z_43;
im43_ = vl_imwbackward(im2double(im4),u_43,v_43) ;

z_53 = H_53(3,1) * u_ + H_53(3,2) * v_ + H_53(3,3) ;
u_53 = (H_53(1,1) * u_ + H_53(1,2) * v_ + H_53(1,3)) ./ z_53 ;
v_53 = (H_53(2,1) * u_+ H_53(2,2) * v_ + H_53(2,3)) ./ z_53;
im53_ = vl_imwbackward(im2double(im5),u_53,v_53) ;


mass = ~isnan(im1_) + ~isnan(im2_)+~isnan(im3_) + ~isnan(im43_)+~isnan(im53_)  ;
% making NOT A Number entry to zero..
im1_(isnan(im1_)) = 0 ;
im2_(isnan(im2_)) = 0 ;
im3_(isnan(im3_)) = 0;
im43_(isnan(im43_)) = 0;
im53_(isnan(im53_)) = 0;

mosaic = (im1_ + im2_+im3_+im43_+im53_)./mass ;
imshow((mosaic));
