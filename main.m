function res = Euclid(r1, r2)
    len = length(r1);
    res = 0;
    for i=1:len
        res += (r1(i)-r2(i))^2;
    end
    % res = sqrt(res);
end

function shrinkedImg = shrinkImg(img, rs)
    [r,c] = size(img);
    shrinkedImg = img(1:rs:r, 1:rs:c);
end

%function to compute the first m leading eigenvectors of a matrix
function [leading_eig, Sigma] = findLeadingEigV( A, m )
    k=size(A,1); % assume A is square
	[V,D]=eig(A); 
	[S,I]=sort(diag(D)); 
	leading_eigV = [];
	for i=1:m
        leading_eigV = [leading_eigV,V(:,I(k-i+1))];
	end
    Sigma=sort(diag(D));
    leading_eig = leading_eigV;    
end


% 0. Initialization

pkg load image;
pkg load strings;

args = argv();

if nargin<1,
    disp('main.m k-Value [fold=1] [image scaling=1] [energy=1] [PCA d]');
    exit;
end

fold=1;

kValue = str2num(args{1});
maxLabel = 0;
rs=1;
cs=1;
energy=1;

if nargin>=2,
    fold = str2num(args{2});
end

if nargin>=3
    rs = str2num(args{3});
    cs = rs;
end

if nargin>=4,
    energy=str2double(args{4});
end

printf('\n*************************\nExperiment: kValue=%d, fold=%d, shrinking=%d, energy=%.3f', kValue, fold, rs, energy);
if nargin>=5,
    printf(', PCAd=%d', args{4});
end
printf('\n*************************\n\n');

% 1. Face Image Cropping and Preprocessing

% 2. Construct ImageDB: Read Images

disp('2. Constructing imageDb...');
if ( ~exist('imageDb.data', "file") )  % if not exists imageDb file
    disp('>>  no imageDb.data. Now creating imageDb...');
    cd dataset;
    folder = dir('.');
    index=0;
    % s=0;
    for i=1:40
        folderName = folder(i+3).name;
        subdir = dir( folderName );
        for j=1:10-fold
            index++;
            imageDb(index).label = i;
            if i>maxLabel,
                maxLabel=i;
            end
            img = imread( strcat( folderName, '/', subdir(j+2).name ) );
            
            % decrease img
            res = shrinkImg(img, rs);

            s = size(res);
            imageDb(index).image = reshape( double(res), s(1)*s(2), 1) ;
        end
    end
    D=s(1)*s(2);
    cd ..;
    save -binary imageDb.data imageDb
else
    load("-binary", "imageDb.data", "imageDb");
    s=size(imageDb(1).image);
    D=s(1)*s(2); % original size
end

% 3. Construct FeatureDB: Extract Features
% imageDb;

% 4. Dimensionality Reduction: PCA
disp('4. Dimensinality Reduction...');
<<<<<<< HEAD
if (~exist('PCAMtx.data', "file") ),
    % calculate xavg, X
    disp('>>  calculate xavg, X');
    n = length(imageDb);
    xavg = double(zeros(D, 1));
    X=double([]);

    for i=1:n
        xavg += double(imageDb(i).image);
    end
    for i=1:D
        xavg(i) = xavg(i)/n;
    end
    for i=1:n
        X=[X imageDb(i).image-xavg];
    end
    % calculate C, Sigma

    disp('>>  calculate C');
    % original program for calculating cov C
    C = (1/n)*X*transpose(X);
    % C = cov(X);
    % size(C)
    % length(C)

    disp('>>  calculate Sigma');
    [P, Sigma] = findLeadingEigV(C,length(C)-1 );
    & size(Sigma)

    % Sigma=diag(Sigma);

    % After achieving P and Sigma, run all possible d and report the best results, based on energy criterion
    disp('>>  calculating d');
    if length(args)>=5,
        d=str2num(args{5});
    else
        d = 0;
        sum = zeros(1, length(Sigma) );
        for i=1:length( Sigma )
            sum += Sigma(i);
        end
    end
    
    temp = zeros(1, length(Sigma) );
    max = 0;
    for i=1:length( Sigma ),
        
        temp += Sigma(i);
        printf('%f  d=%d\n', temp/sum, d);
        if temp/sum > max,
            max = temp/sum;
            d = i;
        end
        if temp/sum > energy,
            d=i;
            break;
        end
    end
    PCAMtx = transpose(P(:,[1:d])); 
    d
    save -binary PCAMtx.data PCAMtx;
else
    load ("-binary", "PCAMtx.data","PCAMtx");
end

% 5. Construct FaceDB: Project Data to low-dimensional space
disp('5. Construct FaceDB'); 
if (~exist('faceDb.data', "file") ),
    dbSize = length(imageDb);

    for i=1:dbSize,
        faceDb(i).label = imageDb(i).label;
        faceDb(i).image = PCAMtx * imageDb(i).image;
    end
    save -binary faceDb.data faceDb;
else
    load ("-binary", "faceDb.data", "faceDb");
end
    


% 6. Classification: Nearest Neighbor

correct = 0;
totalTesting = 0;

cd dataset;
folder = dir('.');
for i=1:40
    folderName = folder(i+3).name;
    subdir = dir( folderName );
    for j=11-fold:10
        totalTesting++;
        testing.label = i;
        img = imread( strcat( folderName, '/', subdir(j+2).name ) );
        s = size(img);
        
        % decrease img
        %{
        [r,c] = size(img);
        temp=[];
        k=1;
        while k<=r,
            temp = [temp;img(k,:)];
            k+=rs;
        end
        k=1;
        res=[];
        while k<=c,
            res=[res, temp(:,k)];
            k+=cs;
        end
        %}
        res = shrinkImg(img, rs); 
        s = size(res);
        testing.image = PCAMtx * reshape( double(res), s(1)*s(2), 1) ;

        % knn
        % 1-distance 2-label
        candidates = [];
        for k=1:length(faceDb),
            candidates(k,1) = Euclid(testing.image, faceDb(k).image);
            candidates(k,2) = faceDb(k).label;
        end

        candidates = sortrows(candidates, 1);
        maxLabel = 40;
        labels = zeros(maxLabel);
        for k=1:kValue
            labels( candidates(k,2) )++;
        end
        res = 0;
        max=0;
        for k=1:maxLabel
            if labels(k)>max,
                max=labels(k);
                res = k;
            end
        end
        printf('>>  testing %3d **  predicted: %4d  real: %4d\n', totalTesting, res, testing.label);
        if res == testing.label,
            correct++;
        end
    end
end
cd ..;

disp(sprintf('accuracy = %d / %d = %f%%', correct, totalTesting, correct/totalTesting*100) );
