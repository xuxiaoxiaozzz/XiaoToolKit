//
//  JsonOConvertController.m
//  XiaoToolKit
//
//  Created by xiaoshiheng on 2024/12/2.
//

#import "JsonOConvertController.h"

@interface JsonOConvertController ()

@property (weak) IBOutlet NSScrollView *jsonText;

@property (weak) IBOutlet NSScrollView *ocText;

@end

@implementation JsonOConvertController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


void (^showErrorAlert)(NSString *) = ^(NSString *message) {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"错误";
    alert.informativeText = message;
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:@"确定"];
    [alert runModal];
};
- (IBAction)clickClearJson:(id)sender {
    NSTextView *jsonView = (NSTextView *)self.jsonText.documentView;
    jsonView.string = @"";
}
- (IBAction)clickClearOC:(id)sender {
    NSTextView *ocView = (NSTextView *)self.ocText.documentView;
    ocView.string = @"";
}
- (IBAction)clickJSONtoOC:(NSButton *)sender {
    
    
    // 有值的一方填入有值的一方
    NSTextView *jsonView = (NSTextView *)self.jsonText.documentView;
    NSTextView *ocView = (NSTextView *)self.ocText.documentView;

    if ((jsonView.string.length > 0 && ocView.string.length > 0) ||
        (jsonView.string.length == 0 && ocView.string.length == 0)) {
        return;
    }

    if (jsonView.string.length > 0) {
        // 验证数据源是否为合法 JSON
        NSData *jsonData = [jsonView.string dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        
        if (error || !jsonObject) {
            showErrorAlert(@"输入的 JSON 数据无效，请检查格式。");
            return;
        }
        
        // to OC: 转为带转义字符的 OC 字符串
        NSString *escapedString = [jsonView.string stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        escapedString = [escapedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        ocView.string = [NSString stringWithFormat:@"@\"%@\"", escapedString];
    }

    if (ocView.string.length > 0) {
        // 去掉字符串前的 `@"` 和最后的 `"`
        NSString *ocString = ocView.string;
        if ([ocString hasPrefix:@"@\""] && [ocString hasSuffix:@"\""]) {
            ocString = [ocString substringWithRange:NSMakeRange(2, ocString.length - 3)];
        }
        
        // 将转义字符 `\"` 恢复为普通的双引号 `"`
        NSString *jsonString = [ocString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        
        // 验证并格式化为合法 JSON
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        
        if (error || !jsonObject) {
            showErrorAlert(@"生成的 JSON 数据无效，请检查数据。");
            return;
        }
        
        // 格式化为美观的 JSON 字符串
        NSData *formattedJsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            showErrorAlert(@"格式化 JSON 时出错，请重试。");
            return;
        }
        
        jsonView.string = [[NSString alloc] initWithData:formattedJsonData encoding:NSUTF8StringEncoding];
    }

}


@end
