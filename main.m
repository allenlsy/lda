




% 0. Initialization
pkg load image;
pkg load strings;


% 1. Face Image Cropping and Preprocessing
rs = 3;
cs = 3;


% 2. Construct ImageDB: Read Images

disp('Constructing imageDb...')
if ( ~exist('imageDb.data', "file") )  % if not exists imageDb file
    disp('  no imageDb.data. Now creating imageDb');
    cd dataset;
    folder = dir('.');
    for i=1:40
        folderName = folder(i+3).name;
        subdir = dir( folderName );
        for j=1:10
            index = (i-1)*10+j
            imageDb(index).label = i;
            img = imread( strcat( folderName, '/', subdir(j+2).name ) );
            s = size(img);
            
            % decrease img
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

D
% 3. Construct FeatureDB: Extract Features
% imageDb;

% 4. Dimensionality Reduction: PCA
disp('Dimensinality Reduction...')

% calculate xavg, X
disp('  calculate xavg, X');
n = length(imageDb)
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
disp('X size');
size(X)
% calculate C, Sigma

disp('  calculate C, Sigma');
C = (1/n)*X*transpose(X);
[P, Sigma] = eig(C);
Sigma=diag(Sigma);

% After achieving P and Sigma, run all possible d and report the best results, based on energy criterion
disp('  calculating d');
sum = zeros(1, length(Sigma) );
for i=1:length( Sigma )
    sum += Sigma(i);
end

temp = zeros(1, length(Sigma) );
max = 0;
for i=1:length( Sigma ),
    temp += Sigma(i);
    if temp/sum > max,
        max = temp/sum;
        d = i;
    end
end
d
PCAMtx = transpose(P(:,[1:d])); 

% 5. Construct FaceDB: Project Data to low-dimensional space
disp('Construct FaceDB');
dbSize = length(imageDb);
size(imageDb(1).image)

for i=1:dbSize,
    faceDb(i).label = imageDb(i).label;
    faceDb(i).image = PCAMtx * imageDb(i).image;
end
length(faceDb)
size(faceDb(1).image)

% 6. Classification: Nearest Neighbor
