function [curlz]=wsc(lat,lon,Tx,Ty)

%input Tx:風応力東西　Ty：風応力南北

rad=pi/180;

[lt, ln]=size(Tx);
a=diff(lat);
dlat=mean(a);
 
deltay=dlat*111176;
curlZ=NaN(lt, ln);
long=NaN(lt, ln);
for ii=1:lt
   for jj=1:ln
           long(ii, jj)=lon(jj)*111176*cos(lat(ii)*rad);
        %long(i,j)=lon(j)*6378137*rad*cos(lat(i)*rad); 
        % [m] earth radious in meters= 6,378,137.0 m.. from wikipedia.
   end % endfor
end % endfor
clear ii jj
% Centeral difference method in x and y 

for ii=2:lt-1
    for jj=2:ln-1
        curlZ(ii, jj)=(Ty(ii, jj+1)-Ty(ii, jj-1))/(2*(long(ii, jj+1)-long(ii, jj-1))) - ...  
            (Tx(ii+1, jj)-Tx(ii-1, jj))/(2*deltay) ;
    end % endfor
end % endfor
clear ii jj
% Forward difference method in x and y 
for jj=1:ln-1
    curlZ(1, jj)=(Ty(1, jj+1)-Ty(1, jj))/(long(1, jj+1)-long(1, jj)) - ...
        (Tx(2, jj)-Tx(1, jj))/deltay ; 
end 
for ii=1:lt-1
    curlZ(ii, 1)=(Ty(ii, 2)-Ty(ii, 1))/(long(ii, 2)-long(ii, 1)) - ...
        (Tx(ii, 2)-Tx(ii, 1))/deltay ;
end
clear ii jj
curlZ(1, ln)=curlZ(1, ln-1);
% Backward difference method in x and y
for ii=2:lt
    curlZ(ii, ln)=(Ty(ii, ln)-Ty(ii, ln-1))/(long(ii, ln)-long(ii, ln-1)) - ...
        (Tx(ii, ln)-Tx(ii-1, ln))/deltay ; 
end
for jj=2:ln-1
    curlZ(lt, jj)=(Ty(lt, jj)-Ty(lt, jj-1))/(long(lt, jj)-long(lt, jj-1)) - ...
        (Tx(lt, jj)-Tx(lt-1, jj))/deltay ;
end
clear ii jj
curlZ(lt, 1)=curlZ(lt, lt-1);
curlz=permute(curlZ,[2 1]);