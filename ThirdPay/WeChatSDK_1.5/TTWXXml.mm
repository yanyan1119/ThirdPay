
#import <Foundation/Foundation.h>
#import "TTWXXml.h"
/*
 XML 解析库
 */
@implementation XMLHelper

-(void) startParse:(NSData *)data
{
    _dictionary =[NSMutableDictionary dictionary];
    _contentString=[NSMutableString string];
    //Demo XML解析实例
    _xmlElements = [[NSMutableArray alloc] init];
    _xmlParser = [[NSXMLParser alloc] initWithData:data];
    [_xmlParser setDelegate:self];
    [_xmlParser parse];
}

-(NSMutableDictionary*)getDict
{
    return _dictionary;
}
//解析文档开始
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
}

- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string
{
    [_contentString setString:string];
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    if( ![_contentString isEqualToString:@"\n"] && ![elementName isEqualToString:@"root"])
    {
        [_dictionary setObject: [_contentString copy] forKey:elementName];
    }
}

//解析文档结束
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

@end