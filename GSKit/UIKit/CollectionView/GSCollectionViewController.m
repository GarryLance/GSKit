//
//  GSCollectionViewController.m
//  GSKitDemo
//
//  Created by OSU on 16/7/28.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GSCollectionViewController.h"
#import "GSDefine.h"

@implementation GSCollectionDataModel


@end



@interface GSCollectionViewController ()

@property (assign, nonatomic) Class gs_itemCalss;
@property (copy, nonatomic) NSString * gs_reuseIdentifier;

@property (assign, nonatomic) Class gs_sectionModelClass;
@property (assign, nonatomic) Class gs_itemModelClass;

@property (strong, nonatomic) NSMutableDictionary * gs_itemFirstLoadBlockDict;//object为回调block, key为sectionModel
@property (strong, nonatomic) NSMutableDictionary * gs_itemWillSetupBlockDict;//object为回调block, key为sectionModel
@property (strong, nonatomic) NSMutableDictionary * gs_itemDidSetupBlockDict;//object为回调block, key为sectionModel

@end



@implementation GSCollectionViewController

#pragma mark Base

- (instancetype)initWithCommonLayoutWithItemSize:(CGSize)itemSize lineSpacing:(CGFloat)lineSpacing itemSpacing:(CGFloat)itemSpacing sectionInset:(UIEdgeInsets)sectionInset scrollDirection:(UICollectionViewScrollDirection)scrollDirection
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = itemSize;//格子大小
    layout.minimumLineSpacing = lineSpacing;
    layout.minimumInteritemSpacing = itemSpacing;
    layout.sectionInset = sectionInset;//每组上左下右空位
    layout.scrollDirection = scrollDirection;//滑动方向
    
    self = [super initWithCollectionViewLayout:layout];
    if (self)
    {
        self.gs_dataModels = [NSMutableDictionary dictionary];
        
        static NSString * const reuseIdentifier = @"GSCollectionViewCell";
        
        //默认的安装方式
        [self     registerItemClass:[GSCollectionViewItem class]
                    reuseIdentifier:reuseIdentifier
                  sectionModelClass:[GSCollectionViewSectionModel class]
                     itemModelClass:[GSCollectionViewItemModel class]];
    }
    return self;
}


- (void)registerItemClass:(Class)itemClass reuseIdentifier:(NSString *)reuseIdentifier sectionModelClass:(Class)sectionModelClass itemModelClass:(Class)itemModelClass
{
    _gs_itemCalss = itemClass;
    _gs_reuseIdentifier = reuseIdentifier;
    _gs_sectionModelClass = sectionModelClass;
    _gs_itemModelClass = itemModelClass;
}


#pragma mark Data

- (void)numberOfSections:(NSInteger)sectionCount numberOfItems:(NSInteger(^)(NSInteger section))itemsCountBlock modelsForSection:(void(^)(__kindof GSCollectionViewSectionModel * sectionModel, NSInteger section))sectionModelBlock modelsForItem:(void(^)(__kindof GSCollectionViewItemModel * itemModel, NSIndexPath * indexPath))itemModelBlock
{
    NSMutableArray * sectionModels = [NSMutableArray arrayWithCapacity:sectionCount];
    NSMutableDictionary * itemsSectionDict = [NSMutableDictionary dictionaryWithCapacity:sectionCount];
    
    for (int i = 0; i < sectionCount; i++)
    {
//        GSDLog(@"section:%d",i)
        id sectionModel = [[_gs_sectionModelClass alloc] init];
        [sectionModels addObject:sectionModel];
        
        //调用设置sectionModel的回调
        if (sectionModelBlock) sectionModelBlock(sectionModel,i);
        
        NSInteger itemCount = itemsCountBlock(i);
        NSMutableArray * itemModels = [NSMutableArray arrayWithCapacity:itemCount];
        for (int j = 0; j < itemCount; j++)
        {
//            GSDLog(@"item:%d",j)
            id itemModel = [[_gs_itemModelClass alloc] init];
            [itemModels addObject:itemModel];
            
            //调用设置itemModel的回调
            if (itemModelBlock) itemModelBlock(itemModel,[NSIndexPath indexPathForItem:j inSection:i]);
        }
        [itemsSectionDict setObject:itemModels forKey:sectionModel];
    }
    
    //将配置好的section和item的模型数据存储到dataModel中，并选中该dataModel使用
    GSCollectionDataModel * dataModel = [[GSCollectionDataModel alloc] init];
    dataModel.gs_sectionModels = sectionModels;
    dataModel.gs_itemsSectionDict = itemsSectionDict;
    self.gs_dataModel = dataModel;
}


- (void)reloadCollectionView
{
    [self.collectionView setContentOffset:CGPointZero animated:NO];
    [self.collectionView reloadData];
}


- (void)saveModelsTag:(NSString *)tag
{
    _gs_dataTag = tag;
    [_gs_dataModels setObject:self.gs_dataModel forKey:tag];
}


- (GSCollectionDataModel *)loadModelsTag:(NSString *)tag
{
    _gs_dataTag = tag;
    GSCollectionDataModel * dataModel = [_gs_dataModels objectForKey:tag];
    self.gs_dataModel = dataModel;
    return dataModel;
}


#pragma mark Action

- (void)blockForItemSection:(GSCollectionViewSectionModel *)sectionModel itemFirstLoadBlock:(GSItemFirstLoadBlock)firtLoadBlock itemWillSetupBlock:(GSItemWillSetupDataBlock)willSetupBlock itemDidSetupBlock:(GSItemDidSetupDataBlock)didSetupBlock
{
    //存储firstLoadBlock
    if (!_gs_itemFirstLoadBlockDict)
    {
        self.gs_itemFirstLoadBlockDict = [NSMutableDictionary dictionaryWithCapacity:_gs_dataModel.gs_sectionModels.count];
    }
    if (firtLoadBlock)
    {
        [_gs_itemFirstLoadBlockDict setObject:firtLoadBlock forKey:sectionModel];
    }
    
    //存储willSetupBlock
    if (!_gs_itemWillSetupBlockDict)
    {
        self.gs_itemWillSetupBlockDict = [NSMutableDictionary dictionaryWithCapacity:_gs_dataModel.gs_sectionModels.count];
    }
    if (willSetupBlock)
    {
        [_gs_itemWillSetupBlockDict setObject:willSetupBlock forKey:sectionModel];
    }
    
    //存储didSetupBlock
    if (!_gs_itemDidSetupBlockDict)
    {
        self.gs_itemDidSetupBlockDict = [NSMutableDictionary dictionaryWithCapacity:_gs_dataModel.gs_sectionModels.count];
    }
    if (didSetupBlock)
    {
        [_gs_itemDidSetupBlockDict setObject:didSetupBlock forKey:sectionModel];
    }
}


#pragma mark Super


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Register cell classes
    [self.collectionView registerClass:[_gs_itemCalss class] forCellWithReuseIdentifier:_gs_reuseIdentifier];
}


#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _gs_dataModel.gs_sectionModels.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = 0;
    //获取sectionModel
    GSCollectionViewSectionModel * sectionModel = [_gs_dataModel.gs_sectionModels objectAtIndex:section];
    if (sectionModel)
    {
        count = [_gs_dataModel.gs_itemsSectionDict objectForKey:sectionModel].count;
    }
    return count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GSCollectionViewItem * cell = [collectionView dequeueReusableCellWithReuseIdentifier:_gs_reuseIdentifier forIndexPath:indexPath];
    
    //获取sectionModel
    GSCollectionViewSectionModel * sectionModel = [_gs_dataModel.gs_sectionModels objectAtIndex:indexPath.section];
    
    //设置回调
    if (_gs_itemFirstLoadBlockDict)
    {
        //设置item首次加载的回调
        cell.gs_itemFirstLoadBlock = [_gs_itemFirstLoadBlockDict objectForKey:sectionModel];
    }
    if (_gs_itemWillSetupBlockDict)
    {
        //设置item即将安装数据的回调
        cell.gs_itemWillSetupDataBlock = [_gs_itemWillSetupBlockDict objectForKey:sectionModel];
    }
    if (_gs_itemDidSetupBlockDict)
    {
        //设置item完成安装数据的回调
        cell.gs_itemDidSetupDataBlock = [_gs_itemDidSetupBlockDict objectForKey:sectionModel];
    }
    
    //设置model
    cell.gs_model = [[_gs_dataModel.gs_itemsSectionDict objectForKey:sectionModel] objectAtIndex:indexPath.item];

    return cell;
}

#pragma mark UICollectionViewDelegate

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_gs_didSelectCollectionViewItemBlock)
    {
        UICollectionViewCell * item = [collectionView cellForItemAtIndexPath:indexPath];
        GSCollectionViewItemModel * itemModel = [[_gs_dataModel.gs_itemsSectionDict objectForKey:[_gs_dataModel.gs_sectionModels objectAtIndex:indexPath.section]] objectAtIndex:indexPath.item];
        _gs_didSelectCollectionViewItemBlock(self, (GSCollectionViewItem *)item, itemModel, indexPath);
    }
}

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
