% 0. Initialization
pkg load image;
pkg load strings;


% 1. Face Image Cropping and Preprocessing



% 2. Construct ImageDB: Read Images
if ( ~exist('imageDb.data', "file") )  % if not exists imageDb file
    cd dataset;
    folder = dir('.')
    for i=1:40
        folderName = folder(i+3).name;
        subdir = dir( folderName );
        for j=1:10
            index = (i-1)*10+j
            imageDb(index).label = i;
            img = imread( strcat( folderName, '/', subdir(j+2).name ) );
            s = size(img);
            imageDb(index).image = reshape( img, s(1)*s(2), 1) ;
        end

    end
    cd ..;
    save -binary imageDb.data imageDb
end

load("-binary", "imageDb.data", "imageDb");

D=s(1)*s(2); % original size

% 3. Construct FeatureDB: Extract Features
% imageDb;

% 4. Dimensionality Reduction: PCA

% calculate xavg, X
n = length(imageDb);
for i=1:n
    xavg += imageDb(1).image;
end
for i=1:n
    X=[X imageDb(i).image-xavg];
end
X

% calculate C, Sigma
C = 1/n*X*transpose(X)
[P, Sigma] = Eig(C)

% After achieving P and Sigma, run all possible d and report the best results, based on energy criterion
sum = zeros(1, length(Sigma) );
for i=1:length( Sigma )
    sum += Sigma(i);
end

temp = zeros(1, length(Sigma) );
max = 0;
for i=1:length( Sigma )
    temp += Sigma(i);
    if temp/sum > max,
        max = temp/sum;
        d = i;
    end
end

% 5. Construct FaceDB: Project Data to low-dimensional space

dbSize = length(imageDb);
for i=1:dbSize
    


% 6. Classification: Nearest Neighbor
