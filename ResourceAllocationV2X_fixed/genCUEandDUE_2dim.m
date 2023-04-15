function [Flag,vehPos,indCUE,indDUE,indDUE2] = genCUEandDUE_2dim(d0, laneWidth, numLane, disBstoHwy, d_avg, numCUE, numDUE)
% 基于函数genCUEandDUE进行二维拓展
% First, generate traffic on the highway according to Spatial Poisson Process with
%      density determined by vehicle speed v (represented by average
%      inter-vehicle distance d_avg = 2.5*v).
%      首先，根据空间泊松过程生成公路上的交通量，其密度由车速v确定（由平均车距d_avg=2.5*v表示）。
% Then, generate DUE and CUE positions.
%      然后，生成D2D用户设备和蜂窝用户设备的位置。
% Input: d0: highway length 
%            汽车与垂点之间的距离（公路长度）
%        d_avg: average inter-vehicle distance, d_avg = 2.5*v
%             汽车之间的平均距离
%        Others should be evident from their names
% Output: Flag, 0/1, if the generated vehicles are not enough, flag = 1
%              如果生成的汽车数量不足，则flag=1
%         vehPos, Nx2 matrix, storing vehicle coordinates
%                 N*2维矩阵，表示汽车的坐标
%         indCUE, numCUEx1, storing indices of CUEs in vehPos
%                 numCUE*1维矩阵，存储vehPos中CUE的索引指数
%         indDUE, numDUEx1, storing indices of DUE transmitter
%                 numDUE*1维矩阵，存储vehPos中DUE的索引指数
%         indDUE2, numDUEx1, storing indices of corresponding DUE receiver,
%                             closest to the DUEs stored in indDUE. 
%                  numDUE*1维矩阵，存储对应的DUE接收机的索引指数，距离indDUE中存储的最近的那一个
% By Le Liang, Georgia Tech, Jan. 25, 2017

vehPos = []; % initilizer for vehicle position  % 初始化
vehPos1 = [];
vehPos2 = [];
indCUE = [];
indDUE = [];
indDUE2 = [];
Flag = 0;
%% generate all vehicle positions and store in vehPos
for ilane = 1:numLane  %循环变量，当前计算到第几条路
    npoints = poissrnd(2*d0/d_avg);  %生成泊松分布的随机数，括号内为泊松分布的均值参数lambda
    %此处是一个标量，表示当前时间或单位时间内的汽车数量
    pproc = (rand(npoints,1)*2-1)*d0; % horizontal coordinates
    %水平坐标，在d0内均匀分布，均值为0
    pproc2 = [pproc, (disBstoHwy+ilane*laneWidth)*ones(length(pproc), 1)]; % [horizon vertical] coordinates
    % 第一列为横坐标，与pproc保持一致，第二列为纵坐标，取决于是在第几条路，在每个循环中，纵坐标值相同
    vehPos1 = [vehPos1; pproc2]; %把当前这条路的坐标记下来，此变量新增两列 
                % 纠正 % 中间用的分号，不是新增两列，是在原有的两列下面延长，增加行数
                % vehPos1表示横向车道上汽车的位置
end

for ilane = 1:numLane  %循环变量，当前计算到第几条路
    npoints = poissrnd(2*d0/d_avg);  %生成泊松分布的随机数，括号内为泊松分布的均值参数lambda
    %此处是一个标量，表示当前时间或单位时间内的汽车数量
    pproc = (rand(npoints,1)*2-1)*d0; % horizontal coordinates
    %水平坐标，在d0内均匀分布，均值为0
    pproc2 = [(disBstoHwy+ilane*laneWidth)*ones(length(pproc), 1) , pproc]; % [horizon vertical] coordinates
    % 第一列为横坐标，与pproc保持一致，第二列为纵坐标，取决于是在第几条路，在每个循环中，纵坐标值相同
    vehPos2 = [vehPos2; pproc2]; %把当前这条路的坐标记下来，此变量新增两列 
                % 纠正 % 中间用的分号，不是新增两列，是在原有的两列下面延长，增加行数
                % vehPos2表示纵向车道上汽车的位置
end
vehPos = [vehPos1; vehPos2];

numVeh = size(vehPos, 1);
if numVeh < numCUE+2*numDUE
    Flag = 1; % the generated vehicles are not enough
    return; 
end
%% generate CUE and DUE positions
indPerm = randperm(numVeh);%randperm随机打乱，得到一个数组
indDUE = indPerm(1:numDUE); % randomly pick numDUE DUEs，为确保此步骤不报错，必须要求43行成立
indDUE2 = zeros(1,numDUE); % corresponding DUE receiver
for ii = 1 : numDUE
    % pair each element in indDUE with closet vehicle and store the
    % index in indDUE2
    % 将最近的两个DUE进行匹配并存储在indDUE2中
    minDist = 2*d0; % 最开始将最小距离设置为可能的最大值，即2倍d0
    tmpInd = 0;  % 当前索引值，暂时变量
    for iii = 1:numVeh % 两层循环求距离，会产生重复
        if any(abs(iii-indDUE)<1e-6) || any(abs(iii-indDUE2)<1e-6) % iii in indDUE or indDUE2
            continue; % 进行iii+1的下一次循环
        end
        newDist = sqrt((vehPos(indDUE(ii), 1)-vehPos(iii,1))^2 + (vehPos(indDUE(ii), 2)-vehPos(iii,2))^2);
        if newDist < minDist
            tmpInd = iii; % 更新当前索引值
            minDist = newDist; % 更新最小距离
        end
    end
    indDUE2(ii) = tmpInd; % the closest DUE pair
    % 这就是indDUE中每个车辆坐标对应的与其距离最近的车辆的坐标
    % 比如indDUE（1，1：2）第一行的两列，分别表示第一辆汽车的横纵坐标（还是纵横坐标来着不重要）的索引值
    % 那么与这辆车距离最近的另一辆车的坐标即为indDUE2（1，1：2）第一行的两列所表示的横纵坐标的索引值
    % 两辆汽车在各自的坐标索引矩阵中的位置相同
end

cntCUE = numDUE+1; % excluding those in indDUE % 不包括indDUE中的那些
% 或许意味着主函数中的numDUE = 20只是目前能发送D2D信号的终端，我们为能发送的车辆终端分配资源
% 而根据43行，当前的车辆总数是必定是大于20的，且不小于numCUE+2*numDUE，所以DUE是成对出现
% 对应两个车辆终端，而剩余的都是CUE，只能接收
while cntCUE <= numVeh
    if any(abs(indPerm(cntCUE)-indDUE2)<1e-6) % element in indDUE2 % indDUE2中的元素
        % do nothing
    else
        indCUE = [indCUE indPerm(cntCUE)];
    end
    cntCUE = cntCUE + 1;
    if length(indCUE) >= numCUE
        break  % 多余的CUE就不考虑了
    end
end
indCUE = indCUE(:);
indDUE = indDUE(:);
indDUE2 = indDUE2(:);

end

