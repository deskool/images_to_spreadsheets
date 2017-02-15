function nearestPtIdx =nearestDirectedPt(pt,pts,distScale,direction,angle)
  % Generate some random points in 2d
  %mu = [0.5, 0.5]; sigma = eye(2);
  %nPts = 40;
  %pts = mvnrnd(mu, sigma, nPts);
  %pts = [this_loc; this_row]'
  %distScale = size(I,1);
  % specify a point, direction and angle to determine nearest pts within an angle
  %pt = [0.25, 0.5];
  %direction = [1 1];
  %angle = 10; % in degrees
  %pt = [this_line_loc;this_line_row]'
  %direction=[1,1];
  %direction = [this_line_loc+1,0]
  
  %angle=10;
  % from pt, construct two points rotated +/- angle/2 of direction; project
  % them some arbitrary, max distance; use standard 2d rotation matrices. From
  % these, construct a triangular region of 'valid' points.
  
  theta = angle/2;
  Rplus = [cosd(theta) -sind(theta); sind(theta) cosd(theta)];
  Rminus = [cosd(-theta) -sind(-theta); sind(-theta) cosd(-theta)];
  
  direction = direction*distScale;
  vertices = [pt; ...
              (direction - pt) * Rplus + pt; ...
              (direction - pt) * Rminus + pt;];

  %fill(vertices(:,1), vertices(:,2), 'b', 'FaceAlpha', 0.3);
  %hold on;

  % Visualize the triangular patch
  %arrow = [pt; direction];
  %plot(arrow(:,1), arrow(:,2));
  %scatter(vertices(:,1), vertices(:,2));

  % Test randomly generated points for membership in the triangle
  in = inpolygon(pts(:,1), pts(:,2), vertices(:,1), vertices(:,2));
  %scatter(pts(in,1), pts(in,2), 25, 'g.');
  %scatter(pts(~in,1), pts(~in,2), 25, 'r.');

  %%  Find closest point within valid region
  validPts = pts(in,:);
  validInds = find(in);
  idx = rangesearch(validPts, pt, distScale);
  nearestPtIdx = validInds(idx{1}(1));
  %scatter(validPts(nearestPtIdx,1), validPts(nearestPtIdx,2), 50, 'x');

  % Plot / Visualize
  %xlim([-5,5]); ylim([-5,5]);
  %hold off
end
