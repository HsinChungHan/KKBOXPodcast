//
//  ObjcEpisode.h
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjcEpisode : NSObject

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSDate* pubDate;
@property (nonatomic, strong) NSString* subtitle;
@property (nonatomic, strong) NSString* author;
@property (nonatomic, strong) NSString* streamUrl;
@property (nonatomic, strong) NSString* summary;
@property (nonatomic, strong) NSString* imageUrl;
@property (nonatomic, strong) NSString* fileUrl;

- (instancetype)initWithTitle:(NSString*)title
             pubDate:(NSDate*)pubDate
            subtitle:(NSString*)subtitle
              author:(NSString*)author
           streamUrl:(NSString*)streamUrl
             summary:(NSString*)summary
            imageUrl:(NSString*)imageUrl
            fileUrl:(NSString*)fileUrl;
@end

NS_ASSUME_NONNULL_END
