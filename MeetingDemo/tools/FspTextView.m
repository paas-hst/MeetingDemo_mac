//
//  FMTextView.m
//  FastMeeting
//
//  Created by Loki-mac on 15/8/10.
//  Copyright (c) 2015年 Loki-mac. All rights reserved.
//

#import "FspTextView.h"

@implementation FspTextView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    _onEnterSginal = [RACSubject subject];

}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
//
//}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if (placeHolderString == nil) {
        NSDictionary *attributeDict = [[NSDictionary alloc] initWithObjectsAndKeys:NSColor.grayColor,NSForegroundColorAttributeName, nil];
        placeHolderString = [[NSAttributedString alloc] initWithString:@"输入消息" attributes:attributeDict];
    }
    
    if ([self.string length] <= 0 && self == self.window.firstResponder) {
        [placeHolderString drawAtPoint:NSMakePoint(0, 0)];
    }
    
    
    // Drawing code here.
}



//- (BOOL)becomeFirstResponder{
//    [self setNeedsDisplay:YES];
//    return [super becomeFirstResponder];
//}
//
//- (BOOL)resignFirstResponder{
//    [self setNeedsDisplay:YES];
//    return [super becomeFirstResponder];
//}

-(void)keyDown:(NSEvent *)theEvent
{
    
    
    unichar c = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    
    if((c == NSEnterCharacter || c == NSCarriageReturnCharacter) && self.markedRange.length == 0)
    {
        if(theEvent.modifierFlags & NSEventModifierFlagShift)
        {
           // [self.textViewDelegate onShiftAndEnterKeyPress];
        }
        else
        {
            [self.onEnterSginal sendNext:nil];
        }
        
        return;
    }
   
    [super keyDown:theEvent];
}
@end
