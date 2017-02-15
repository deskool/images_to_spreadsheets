function [xs,ys] = cint(x1,y1,x2,y2)

%   [xs,ys] = cint(x1,y1,x2,y2) finds intersection points of the curves
%   defined by straight lines between the length(x1) points in the plane,
%   (x1,y1), and the length(x2) points in the plane (x2,y2).
%
%   The function essentially solves
%
%   x1(m) + t*diff(x1)(m) = x2(n) + s*diff(x2)(n);
%   y1(m) + t*diff(y1)(m) = y2(n) + s*diff(y2)(n);
%
%   for each combination of line segments and returns
%
%   xs = x1 + t*dx1;
%   ys = y1 + t*dy1;
%
%   for all t for which 0<t<1 and 0<s<1 corresponding to an 
%   intersection. 
%
%   For efficiency the function uses bsxfun to construct the length(x1) x
%   length(x2) matrices involved in the calculation.
%
%   Points shared by the two arrays (x1,y1) and (x2,y2) are also returned.
%
%   Type cint with no arguments to see an example with random curves.
%
%   Johan Rønby, October 6 2009
%

if nargin < 1
    x1 = rand(1,500);
    y1 = rand(1,500);
    x2 = rand(1,500);
    y2 = rand(1,500);
    tic
end

x1 = x1(:); y1 = y1(:); x2 = x2(:).'; y2 = y2(:).';

%Finding points common to the two arrays
C = intersect([x1, y1],[x2.', y2.'],'rows');
xs1 = C(:,1);
ys1 = C(:,2);
clear C

%Finding intersections of line segements
dx = bsxfun(@minus,x2(1:end-1),x1(1:end-1));
dy = bsxfun(@minus,y2(1:end-1),y1(1:end-1));
D = bsxfun(@times,diff(y2),diff(x1))-bsxfun(@times,diff(x2),diff(y1));
t = bsxfun(@times,diff(y2),dx)...
        - bsxfun(@times,diff(x2),dy);
t = t./D;
s = bsxfun(@times,dx,diff(y1))...
        - bsxfun(@times,dy,diff(x1));
s = s./D;
Is = s >= 0 & s <= 1;
It = t >= 0 & t <= 1;
ind = find(Is & It);
[n,m] = ind2sub(size(s),ind);
C(:,1) = x1(n) + t(ind).*(x1(n+1)-x1(n));
C(:,2) = y1(n) + t(ind).*(y1(n+1)-y1(n));
C = unique(C,'rows');
xs = C(:,1); ys = C(:,2);

if nargin < 1
    t = toc;
    figure(2); clf 
    plot(x1,y1,'.-r',x2,y2,'.-',xs,ys,'ok')
    legend('Curve 1', 'Curve 2', 'Intersections')
    title([num2str(length(xs)) ' intersection points found in ' num2str(t) ' seconds'])
end