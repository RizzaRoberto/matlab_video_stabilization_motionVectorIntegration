f = figure;
video = VideoReader('video_finale.mp4');  %change here the target video
prev_frame = readFrame(video);

hbm = vision.BlockMatcher('ReferenceFrameSource','Input port','BlockSize',[15,15], 'MaximumDisplacement', [50 50],'SearchMethod','Three-step');%(30,30) (49,49)-(30,30) per il video TEST2 Three-step  %impostando il MaximunDisplacement ho ottenuto un miglioramento (aumento il raggio di ricerca)
hbm.OutputValue = 'Horizontal and vertical components in complex form';  

integrated = 0;
integrated_prev = 0;
prev_frame = im2double(im2gray(prev_frame));

while hasFrame(video)    
    next_frame = readFrame(video);
    next_frame2 = next_frame;
    
    next_frame = im2double(im2gray(next_frame));
    
    motion = hbm(next_frame,prev_frame);
    dim = size(motion,1) * size(motion,2);
%   I obtain a global movement vector by averaging the horizontal and vertical components of the blocks
    horizontal = sum(real(motion(:,:)));
    vertical = sum(imag(motion(:,:)));
    horizontal1 = sum(horizontal);
    vertical1 = sum(vertical);
   
    GMV = complex(horizontal1/dim,vertical1/dim);
    % calculation of the correction vector and its components, using the GMI (Global Motion Integration) method
    integrated = 0.92 * integrated_prev + GMV;

   
    R = real(integrated);
    I = imag(integrated);
    vector_corr = [R I];
    
    
    % I obtain the stabilised image by translating the correction vector
    imm_stabilized = imtranslate(next_frame2, vector_corr);
    
    imm_stabilized_cropped = imcrop(imm_stabilized,[30 30 250 190]);   
    subplot(1,2,1);
    imshow(next_frame2);
    subplot(1,2,2);
    imshow(imm_stabilized);
    %imshow(imm_stabilized_cropped);

    integrated_prev = integrated;
    prev_frame = next_frame;
     
    
        
    pause(1/(video.FrameRate));

      if f.CurrentCharacter > 0
          break;
      end
end
disp("out");
%close(v1);
%close(v2);