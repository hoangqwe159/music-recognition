function I = normxcorr2e(template, im, shape)
%  Computes The Normalized Cross-correlation 
%   Inputs, template, binary image and shape
%   Outputs, a matrix contains the correlation coefficients.
  if (nargin == 2) || strcmp(shape,'full')
      I = normxcorr2(template, im);
      return
  end

  switch shape
      % The size of output image is same as input image
      case 'same'
          pad = floor(size(template)./2);
          center = size(im);
      case 'valid'
          pad = size(template) - 1;
          center = size(im) - pad;
      otherwise
          throw(Mexception('normxcorr2e:BadInput',...
              'SHAPE must be ''full'', ''same'', or ''valid''.'));
  end

  I = normxcorr2(template, im);
  I = I([false(1,pad(1)) true(1,center(1))], ...
        [false(1,pad(2)) true(1,center(2))]);

end