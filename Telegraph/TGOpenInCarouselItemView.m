#import "TGOpenInCarouselItemView.h"

#import <LegacyComponents/LegacyComponents.h>

#import "TGOpenInCarouselCell.h"

#import "TGOpenInAppItem.h"

@interface TGOpenInCarouselItemView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
{
    NSArray *_appItems;
    
    UILabel *_titleLabel;
    UICollectionView *_collectionView;
    
    TGMenuSheetPallete *_pallete;
    UIImage *_cornersImage;
}
@end

@implementation TGOpenInCarouselItemView

- (instancetype)initWithAppItems:(NSArray *)appItems title:(NSString *)title
{
    self = [super initWithType:TGMenuSheetItemTypeDefault];
    if (self != nil)
    {
        _appItems = appItems;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(80, 107);
        layout.minimumInteritemSpacing = 0.0f;
        layout.minimumLineSpacing = 2.0f;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        if (iosMajorVersion() >= 11)
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _collectionView.alwaysBounceHorizontal = true;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.showsVerticalScrollIndicator = false;
        [_collectionView registerClass:[TGOpenInCarouselCell class] forCellWithReuseIdentifier:TGOpenInCarouselCellIdentifier];
        [self addSubview:_collectionView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.font = TGMediumSystemFontOfSize(20.0f);
        _titleLabel.text = title;
        _titleLabel.textColor = [UIColor blackColor];
        [_titleLabel sizeToFit];
        _titleLabel.userInteractionEnabled = false;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)dealloc
{
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

- (void)setPallete:(TGMenuSheetPallete *)pallete
{
    [super setPallete:pallete];
    
    _pallete = pallete;
    
    _titleLabel.textColor = pallete.textColor;
    _titleLabel.backgroundColor = pallete.backgroundColor;
    _collectionView.backgroundColor = pallete.backgroundColor;
    
    CGFloat radius = 16.0f;
    CGRect rect = CGRectMake(0, 0, radius * 2 + 1.0f, radius * 2 + 1.0f);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    CGContextSetFillColorWithColor(context, pallete.backgroundColor.CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillEllipseInRect(context, rect);
    
    CGContextRestoreGState(context);
    
    CGContextSetStrokeColorWithColor(context, pallete.separatorColor.CGColor);
    CGContextSetLineWidth(context, 0.5f);
    CGContextStrokeEllipseInRect(context, CGRectInset(rect, 0.5f, 0.5f));
    
    _cornersImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(radius, radius, radius, radius)];
    
    UIGraphicsEndImageContext();
    
    for (TGOpenInCarouselCell *cell in _collectionView.visibleCells)
    {
        [cell setCornersImage:_cornersImage];
    }
}

#pragma mark - 

- (NSInteger)collectionView:(UICollectionView *)__unused collectionView numberOfItemsInSection:(NSInteger)__unused section
{
    return _appItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TGOpenInCarouselCell *cell = (TGOpenInCarouselCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TGOpenInCarouselCellIdentifier forIndexPath:indexPath];
    
    cell.pallete = _pallete;
    TGOpenInAppItem *appItem = (TGOpenInAppItem *)_appItems[indexPath.row];
    [cell setAppItem:appItem];
    [cell setCornersImage:_cornersImage];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)__unused collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.itemPressed != nil)
        self.itemPressed();
    
    TGOpenInAppItem *appItem = (TGOpenInAppItem *)_appItems[indexPath.row];
    [appItem performOpenIn];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)__unused collectionView layout:(UICollectionViewLayout *)__unused collectionViewLayout insetForSectionAtIndex:(NSInteger)__unused section
{
    return UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, 6.0f);
}

#pragma mark -

- (bool)requiresDivider
{
    return true;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)__unused width screenHeight:(CGFloat)__unused screenHeight
{
    return 148;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _titleLabel.frame = CGRectMake(floor((self.frame.size.width - _titleLabel.frame.size.width) / 2), 16.0f, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
    _collectionView.frame = CGRectMake(0, 36.0f, self.frame.size.width, self.frame.size.height - 36.0f);
}

@end
