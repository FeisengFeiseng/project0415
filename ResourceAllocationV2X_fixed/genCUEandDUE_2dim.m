function [Flag,vehPos,indCUE,indDUE,indDUE2] = genCUEandDUE_2dim(d0, laneWidth, numLane, disBstoHwy, d_avg, numCUE, numDUE)
% ���ں���genCUEandDUE���ж�ά��չ
% First, generate traffic on the highway according to Spatial Poisson Process with
%      density determined by vehicle speed v (represented by average
%      inter-vehicle distance d_avg = 2.5*v).
%      ���ȣ����ݿռ䲴�ɹ������ɹ�·�ϵĽ�ͨ�������ܶ��ɳ���vȷ������ƽ������d_avg=2.5*v��ʾ����
% Then, generate DUE and CUE positions.
%      Ȼ������D2D�û��豸�ͷ����û��豸��λ�á�
% Input: d0: highway length 
%            �����봹��֮��ľ��루��·���ȣ�
%        d_avg: average inter-vehicle distance, d_avg = 2.5*v
%             ����֮���ƽ������
%        Others should be evident from their names
% Output: Flag, 0/1, if the generated vehicles are not enough, flag = 1
%              ������ɵ������������㣬��flag=1
%         vehPos, Nx2 matrix, storing vehicle coordinates
%                 N*2ά���󣬱�ʾ����������
%         indCUE, numCUEx1, storing indices of CUEs in vehPos
%                 numCUE*1ά���󣬴洢vehPos��CUE������ָ��
%         indDUE, numDUEx1, storing indices of DUE transmitter
%                 numDUE*1ά���󣬴洢vehPos��DUE������ָ��
%         indDUE2, numDUEx1, storing indices of corresponding DUE receiver,
%                             closest to the DUEs stored in indDUE. 
%                  numDUE*1ά���󣬴洢��Ӧ��DUE���ջ�������ָ��������indDUE�д洢���������һ��
% By Le Liang, Georgia Tech, Jan. 25, 2017

vehPos = []; % initilizer for vehicle position  % ��ʼ��
vehPos1 = [];
vehPos2 = [];
indCUE = [];
indDUE = [];
indDUE2 = [];
Flag = 0;
%% generate all vehicle positions and store in vehPos
for ilane = 1:numLane  %ѭ����������ǰ���㵽�ڼ���·
    npoints = poissrnd(2*d0/d_avg);  %���ɲ��ɷֲ����������������Ϊ���ɷֲ��ľ�ֵ����lambda
    %�˴���һ����������ʾ��ǰʱ���λʱ���ڵ���������
    pproc = (rand(npoints,1)*2-1)*d0; % horizontal coordinates
    %ˮƽ���꣬��d0�ھ��ȷֲ�����ֵΪ0
    pproc2 = [pproc, (disBstoHwy+ilane*laneWidth)*ones(length(pproc), 1)]; % [horizon vertical] coordinates
    % ��һ��Ϊ�����꣬��pproc����һ�£��ڶ���Ϊ�����꣬ȡ�������ڵڼ���·����ÿ��ѭ���У�������ֵ��ͬ
    vehPos1 = [vehPos1; pproc2]; %�ѵ�ǰ����·��������������˱����������� 
                % ���� % �м��õķֺţ������������У�����ԭ�е����������ӳ�����������
                % vehPos1��ʾ���򳵵���������λ��
end

for ilane = 1:numLane  %ѭ����������ǰ���㵽�ڼ���·
    npoints = poissrnd(2*d0/d_avg);  %���ɲ��ɷֲ����������������Ϊ���ɷֲ��ľ�ֵ����lambda
    %�˴���һ����������ʾ��ǰʱ���λʱ���ڵ���������
    pproc = (rand(npoints,1)*2-1)*d0; % horizontal coordinates
    %ˮƽ���꣬��d0�ھ��ȷֲ�����ֵΪ0
    pproc2 = [(disBstoHwy+ilane*laneWidth)*ones(length(pproc), 1) , pproc]; % [horizon vertical] coordinates
    % ��һ��Ϊ�����꣬��pproc����һ�£��ڶ���Ϊ�����꣬ȡ�������ڵڼ���·����ÿ��ѭ���У�������ֵ��ͬ
    vehPos2 = [vehPos2; pproc2]; %�ѵ�ǰ����·��������������˱����������� 
                % ���� % �м��õķֺţ������������У�����ԭ�е����������ӳ�����������
                % vehPos2��ʾ���򳵵���������λ��
end
vehPos = [vehPos1; vehPos2];

numVeh = size(vehPos, 1);
if numVeh < numCUE+2*numDUE
    Flag = 1; % the generated vehicles are not enough
    return; 
end
%% generate CUE and DUE positions
indPerm = randperm(numVeh);%randperm������ң��õ�һ������
indDUE = indPerm(1:numDUE); % randomly pick numDUE DUEs��Ϊȷ���˲��費��������Ҫ��43�г���
indDUE2 = zeros(1,numDUE); % corresponding DUE receiver
for ii = 1 : numDUE
    % pair each element in indDUE with closet vehicle and store the
    % index in indDUE2
    % �����������DUE����ƥ�䲢�洢��indDUE2��
    minDist = 2*d0; % �ʼ����С��������Ϊ���ܵ����ֵ����2��d0
    tmpInd = 0;  % ��ǰ����ֵ����ʱ����
    for iii = 1:numVeh % ����ѭ������룬������ظ�
        if any(abs(iii-indDUE)<1e-6) || any(abs(iii-indDUE2)<1e-6) % iii in indDUE or indDUE2
            continue; % ����iii+1����һ��ѭ��
        end
        newDist = sqrt((vehPos(indDUE(ii), 1)-vehPos(iii,1))^2 + (vehPos(indDUE(ii), 2)-vehPos(iii,2))^2);
        if newDist < minDist
            tmpInd = iii; % ���µ�ǰ����ֵ
            minDist = newDist; % ������С����
        end
    end
    indDUE2(ii) = tmpInd; % the closest DUE pair
    % �����indDUE��ÿ�����������Ӧ�������������ĳ���������
    % ����indDUE��1��1��2����һ�е����У��ֱ��ʾ��һ�������ĺ������꣨�����ݺ��������Ų���Ҫ��������ֵ
    % ��ô�������������������һ���������꼴ΪindDUE2��1��1��2����һ�е���������ʾ�ĺ������������ֵ
    % ���������ڸ��Ե��������������е�λ����ͬ
end

cntCUE = numDUE+1; % excluding those in indDUE % ������indDUE�е���Щ
% ������ζ���������е�numDUE = 20ֻ��Ŀǰ�ܷ���D2D�źŵ��նˣ�����Ϊ�ܷ��͵ĳ����ն˷�����Դ
% ������43�У���ǰ�ĳ��������Ǳض��Ǵ���20�ģ��Ҳ�С��numCUE+2*numDUE������DUE�ǳɶԳ���
% ��Ӧ���������նˣ���ʣ��Ķ���CUE��ֻ�ܽ���
while cntCUE <= numVeh
    if any(abs(indPerm(cntCUE)-indDUE2)<1e-6) % element in indDUE2 % indDUE2�е�Ԫ��
        % do nothing
    else
        indCUE = [indCUE indPerm(cntCUE)];
    end
    cntCUE = cntCUE + 1;
    if length(indCUE) >= numCUE
        break  % �����CUE�Ͳ�������
    end
end
indCUE = indCUE(:);
indDUE = indDUE(:);
indDUE2 = indDUE2(:);

end

