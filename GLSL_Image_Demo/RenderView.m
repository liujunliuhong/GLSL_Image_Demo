//
//  RenderView.m
//  GLSL_Image_Demo
//
//  Created by apple on 2020/7/31.
//  Copyright © 2020 yinhe. All rights reserved.
//

#import "RenderView.h"
#import <OpenGLES/ES3/gl.h>

@interface RenderView()
@property (nonatomic, strong) CAEAGLLayer *eagLayer;
@property (nonatomic, strong) EAGLContext *eaglContext;

@property (nonatomic, assign) GLuint colorRenderBuffer;
@property (nonatomic, assign) GLuint colorFrameBuffer;

@property (nonatomic, assign) GLuint programe;
@end



@implementation RenderView

- (void)setupLayer{
    self.eagLayer = (CAEAGLLayer *)self.layer;
}


@end
