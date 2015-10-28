
#import <Foundation/Foundation.h>
/*
 XML 解析库api说明：
 //============================================================================
 
 //输入参数为xml格式串，初始化解析器
 -(void)startParse:(NSData *)data;
 
 //获取解析后的字典
 -(NSMutableDictionary*) getDict;
 
 //============================================================================
 */
@interface XMLHelper : NSObject<NSXMLParserDelegate>
{
    //解析器
    NSXMLParser *_xmlParser;
    //解析元素
    NSMutableArray *_xmlElements;
    //解析结果
    NSMutableDictionary *_dictionary;
    //临时串变量
    NSMutableString *_contentString;
}
//输入参数为xml格式串，初始化解析器
-(void)startParse:(NSData *)data;


//获取解析后的字典
-(NSMutableDictionary*) getDict;

@end
