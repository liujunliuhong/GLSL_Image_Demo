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

@property (nonatomic, assign) GLuint renderBufferID;
@property (nonatomic, assign) GLuint frameBufferID;

@property (nonatomic, assign) GLuint programeID;
@end



@implementation RenderView

// 重写layerClass
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

// 设置layer
- (void)setupLayer{
    self.eagLayer = (CAEAGLLayer *)self.layer;
    
    // 设置scale
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    
    // 描述属性
    self.eagLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @(NO),
                                         kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
}

// 设置上下文
- (void)setupContext{
    self.eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!self.eaglContext) {
        NSLog(@"Creat Context Failed!");
        return;
    }
    
    [EAGLContext setCurrentContext:self.eaglContext];
}

// 清空缓冲区
- (void)deleteRenderAndFrameBuffer{
    glDeleteBuffers(1, &_renderBufferID);
    self.renderBufferID = 0;
    
    glDeleteBuffers(1, &_frameBufferID);
    self.frameBufferID = 0;
}

// 设置RenderBuffer和FrameBuffer
- (void)setupRenderBufferAndFrameBuffer{
    GLuint renderBufferID;
    glGenBuffers(1, &renderBufferID);
    self.renderBufferID = renderBufferID;
    // 将标识符绑定到`GL_RENDERBUFFER`
    glBindRenderbuffer(GL_RENDERBUFFER, self.renderBufferID);
    // 将可绘制对象`CAEAGLLayer`的存储绑定到`RenderBuffer`对象
    [self.eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eagLayer];
    
    GLuint frameBufferID;
    glGenBuffers(1, &frameBufferID);
    self.frameBufferID = frameBufferID;
    // 将标识符绑定到`GL_FRAMEBUFFER`
    glBindFramebuffer(GL_FRAMEBUFFER, self.frameBufferID);
    // 将`renderBufferID`通过`glFramebufferRenderbuffer`函数绑定到`GL_COLOR_ATTACHMENT0`
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.renderBufferID);
}

- (void)renderLayer{
    // 初始化背景颜色，清理缓存，并设置视口大小
    glClearColor(0.3f, 0.45f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    CGFloat scale = [[UIScreen mainScreen]scale];
    glViewport(self.frame.origin.x * scale, self.frame.origin.y * scale, self.frame.size.width * scale, self.frame.size.height * scale);
    
    // GLSL自定义着色器加载
    NSString *vertexFile = [[NSBundle mainBundle]pathForResource:@"shaderv" ofType:@"vsh"];
    NSString *fragmentFile = [[NSBundle mainBundle]pathForResource:@"shaderf" ofType:@"fsh"];
    
    // 加载shader
    self.programeID = [self loadShaderWithVertexPath:vertexFile fragmentPath:fragmentFile];
    
    // 链接
    glLinkProgram(self.programeID);
    
    // 判断链接状态
    GLint linkStatus;
    glGetProgramiv(self.programeID, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLchar message[1024];
        glGetProgramInfoLog(self.programeID, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"Program Link Error:%@",messageString);
        return;
    }
    
    // 使用program
    glUseProgram(self.programeID);
    
    
    
    
}

- (GLuint)loadShaderWithVertexPath:(NSString *)vertexPath fragmentPath:(NSString *)fragmentPath{
    // 定义顶点着色器ID、片元着色器ID
    GLuint vertexShaderID;
    GLuint fragmentShaderID;
    
    // 创建program
    GLint programID = glCreateProgram();
    
    // 编译顶点着色器程序
    [self compileShader:&vertexShaderID type:GL_VERTEX_SHADER filePath:vertexPath];
    [self compileShader:&fragmentShaderID type:GL_FRAGMENT_SHADER filePath:fragmentPath];
    
    // 创建最终的程序
    glAttachShader(programID, vertexShaderID);
    glAttachShader(programID, fragmentShaderID);
    
    // 释放
    glDeleteShader(vertexShaderID);
    glDeleteShader(fragmentShaderID);
    
    return programID;
}

- (void)compileShader:(GLuint *)shader type:(GLenum)type filePath:(NSString *)filePath{
    // 读取文件路径字符串
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    const GLchar *source = (GLchar *)[content UTF8String];
    // 创建一个shader（根据type类型）
    *shader = glCreateShader(type);
    // 将着色器源码附加到着色器对象上。
    // 参数1：shader,要编译的着色器对象 *shader
    // 参数2：numOfStrings,传递的源码字符串数量 1个
    // 参数3：strings,着色器程序的源码（真正的着色器程序源码）
    // 参数4：lenOfStrings,长度，具有每个字符串长度的数组，或NULL，这意味着字符串是NULL终止的
    glShaderSource(*shader, 1, &source, NULL);
    // 把着色器源代码编译成目标代码
    glCompileShader(*shader);
}
@end



