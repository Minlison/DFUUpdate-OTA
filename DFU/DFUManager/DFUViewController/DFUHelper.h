/*
 * Copyright (c) 2015, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Foundation/Foundation.h>
#import "DFUOperations.h"
#import "InitData.h"

@interface DFUHelper : NSObject

@property (strong, nonatomic) DFUOperations *dfuOperations;
@property (strong, nonatomic) NSURL *selectedFileURL;
@property (strong, nonatomic) NSURL *appJsonFileURL;
@property (strong, nonatomic) NSURL *softdeviceURL;
@property (strong, nonatomic) NSURL *bootloaderURL;
@property (strong, nonatomic) NSURL *applicationURL;
@property (strong, nonatomic) NSURL *applicationMetaDataURL;
@property (strong, nonatomic) NSURL *bootloaderMetaDataURL;
@property (strong, nonatomic) NSURL *softdeviceMetaDataURL;
@property (strong, nonatomic) NSURL *systemMetaDataURL;
@property (strong, nonatomic) NSURL *softdevice_bootloaderURL;
@property (strong, nonatomic) NSURL *manifestFileURL;
@property (assign, nonatomic) NSUInteger selectedFileSize;
@property (assign, nonatomic) uint32_t bootloaderSize;
@property (assign, nonatomic) uint32_t softdeviceSize;
@property (nonatomic, strong) NSArray *manifestData;
@property (assign, nonatomic) DfuFirmwareTypes enumFirmwareType;

@property (assign, nonatomic) int dfuVersion;
@property (assign, nonatomic) BOOL isSelectedFileZipped;
@property (assign, nonatomic) BOOL isDfuVersionExist;
@property (assign, nonatomic) BOOL isManifestExist;

-(void)checkAndPerformDFU;
-(void)unzipFiles:(NSURL *)zipFileURL;
-(void) setFirmwareType:(NSString *)firmwareType;
-(BOOL)isInitPacketFileExist;
-(BOOL)isValidFileSelected;
-(NSString *)getUploadStatusMessage;
-(NSString *)getInitPacketFileValidationMessage;
-(NSString *)getFileValidationMessage;
-(DFUHelper *)initWithData:(DFUOperations *)dfuOperations;


@end
