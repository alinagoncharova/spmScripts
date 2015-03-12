function nii_change_datatype (fname, newType)
%Change format of stored image data
% fname : name of file to convert
% newType : desired format of converted image uint8=2; int16=4; int32=8; float32=16; float64=64
%Chris Rorden 8/2014
% http://opensource.org/licenses/BSD-2-Clause
%Examples
%   nii_change_datatype; %GUI
%   nii_change_datatype('C:\dir\img.nii', 16);
if ~exist('fname','var') %no image
    fname = spm_select(1,'image','Select image to convert');
    [pth,nam,ext] = spm_fileparts( fname);
    fname = fullfile(pth,[ nam, ext]); %'img.nii,1' -> 'img.nii'
end
if ~exist('newType','var')
	newType = cell2mat(inputdlg('Enter desired data type (2=uint8, 4=int16, 16=float32):', 'Sample', 1,{'4'}));
    newType = str2double(newType);
end
[pth,nam,ext] = spm_fileparts( fname);
hdr = spm_vol (deblank (fname));
img = spm_read_vols (hdr);
nV = size(img,4); %[nX nY nZ nV] = size(XYZV);
hdr = hdr(1); %required for multi-volume files
hdr.fname = fullfile(pth,['p' nam ext]);
hdr.dt    =[newType,0];
if (spm_type(hdr.dt,'intt')) %integer output
    %from spm_file_merge
    fprintf('Saving %s as integers with %d-bits per voxel\n',hdr.fname, spm_type(hdr.dt,'bits'));
    if (sum(isnan(img(:))) > 0) 
        fprintf('Warning: converting %d not-a-number values to zero!\n',sum(isnan(img(:))));
        img(isnan(img(:))) = 0;
    end
    dmx  = spm_type(hdr.dt,'maxval');
    dmn  = spm_type(hdr.dt,'minval');
    mx = max(img(:));
    mn = min(img(:));
    if dmn < 0
    	sf = max(mx/dmx,-mn/dmn);
    else
    	sf = mx/dmx;
    end
    hdr.pinfo = [sf;0;0];
else
    
    fprintf('Saving %s as real-numbers (floating point) with %d-bits per voxel\n',hdr.fname, spm_type(hdr.dt,'bits'));
    hdr.pinfo = [1;0;0]; 
end
img(2) = -inf;
for v=1:nV
    hdr.n(1)=v;
    spm_write_vol(hdr,img(:, :, :, v));
end