//
//  ObjcEpisode.m
//  KKBOXPodcast
//
//  Created by Chung Han Hsin on 2021/2/25.
//

#import "ObjcEpisode.h"
#import <FeedKit/FeedKit-Swift.h>


@implementation ObjcEpisode


-(instancetype)initWithTitle:(NSString*)title
           pubDate:(NSDate*)pubDate
          subtitle:(NSString*)subtitle
            author:(NSString*)author
         streamUrl:(NSString*)streamUrl
           summary:(NSString*)summary
          imageUrl:(NSString*)imageUrl
           fileUrl:(NSString*)fileUrl
{
    if (!(self = [super init]))
        return nil;
    self.title = title;
    self.pubDate = pubDate;
    self.subtitle = subtitle;
    self.author = author;
    self.streamUrl = streamUrl;
    self.imageUrl = imageUrl;
    self.fileUrl = fileUrl;
    return self;
}

@end
