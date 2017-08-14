function [crossingPoint, crossing] = lineCrossing (line1, line2)

m1 = (line1 (2,2)  - line1 (1,2))/(line1 (2,1) - line1 (1,1));
m2 = (line2 (2,2)  - line2 (1,2))/(line2 (2,1) - line2 (1,1));

if (m1 == m2 || (isinf(m1) && isinf(m2)))
    crossingPoint = 0;
    crossing = 0;
    return;
end;

if (isinf (m1) || isinf (m2))
   if isinf (m1)
       aux = line2;
       line2 = line1;
       line1 = aux;
       aux = m2;
       m2 = m1;
       m1 = aux;
   end
   b1 = line1(2,2) - m1*line1(2,1);
   xintersect = line2(1,1);
   yintersect = m1*xintersect + b1;
   crossingPoint = [xintersect; yintersect];
   crossing = 0;
   return;
end

intercept = @(line,m) line(1,2) - m*line(1,1);
b1 = intercept(line1,m1);
b2 = intercept(line2,m2);
xintersect = (b2-b1)/(m1-m2);
yintersect = m1*xintersect + b1;

isPointInside = @(xint,myline) ...
    (xint >= myline(1,1) && xint <= myline(2,1)) || ...
    (xint >= myline(2,1) && xint <= myline(1,1));
inside = isPointInside(xintersect,line1) && ...
         isPointInside(xintersect,line2);

crossingPoint = [xintersect; yintersect];
crossing = inside;