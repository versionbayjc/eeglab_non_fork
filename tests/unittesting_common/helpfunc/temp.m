axis([0 1 1 2 -1 0]);
hold on;
% x = 0:0.01:1;
% y = 1-x;
% z = zeros(size(x));
% plot3(x,y,z,'LineWidth',2);
% hold on;
% x = 0:0.01:1;
% z = 1-x;
% y = zeros(size(x));
% plot3(x,y,z,'LineWidth',2);
% hold on;
% z = 0:0.01:1;
% y = 1-x;
% x = zeros(size(x));
% plot3(x,y,z,'LineWidth',2);
% hold on;
clear;
v0 = [0.804852,1.61548,-0.472712];

v1 = [0.842831,1.55966,-0.49501];

v2 = [0.49501,1.55866,-0.84283];
line([v0(1),v1(1)],[v0(2),v1(2)],[v0(3),v1(3)]);
hold on;
line([v0(1),v2(1)],[v0(2),v2(2)],[v0(3),v2(3)]);
hold on;
line([v1(1),v2(1)],[v1(2),v2(2)],[v1(3),v2(3)]);
hold on;
text(v0(1),v0(2),v0(3),'   V0');
text(v1(1),v1(2),v1(3),'   V1');
text(v2(1),v2(2),v2(3),'   V2');
% line(v0,v2);
% hold on;
% line(v1,v2);
% hold on;