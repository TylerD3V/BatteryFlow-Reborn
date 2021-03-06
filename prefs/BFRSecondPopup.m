#import "BFRSecondPopup.h"

@implementation BFRSecondPopup
+ (NSString *)hb_specifierPlist {
	return @"SecondPopup";
}
- (NSMutableArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"SecondPopup" target:self];
		[self applyModificationsToSpecifiers:_specifiers];
	}
	return _specifiers;
}
- (void)applyModificationsToSpecifiers:(NSMutableArray *)specifiers {
	_allSpecifiers = [specifiers copy];
	[self removeDisabledGroups:specifiers];
}
- (void)removeDisabledGroups:(NSMutableArray *)specifiers {
	for (PSSpecifier *specifier in [specifiers reverseObjectEnumerator]) {
		NSNumber *nestedEntryCount = [[specifier properties] objectForKey:@"nestedEntryCount"];
		if (nestedEntryCount) {
			BOOL enabled = [[self readPreferenceValue:specifier] boolValue];
			if (!enabled) {
				NSMutableArray *nestedEntries = [[_allSpecifiers subarrayWithRange:NSMakeRange([_allSpecifiers indexOfObject:specifier]+1, [nestedEntryCount intValue])] mutableCopy];
				BOOL containsNestedEntries = NO;
				for (PSSpecifier *nestedEntry in nestedEntries) {
					NSNumber *nestedNestedEntryCount = [[nestedEntry properties] objectForKey:@"nestedEntryCount"];
					if (nestedNestedEntryCount) {
						containsNestedEntries = YES;
						break;
					}
				}
				if (containsNestedEntries) {
					[self removeDisabledGroups:nestedEntries];
				}
				[specifiers removeObjectsInArray:nestedEntries];
			}
		}
	}
}
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];
	if (specifier.cellType == PSSwitchCell) {
		NSNumber *numValue = (NSNumber *)value;
		NSNumber *nestedEntryCount = [[specifier properties] objectForKey:@"nestedEntryCount"];
		if (nestedEntryCount) {
			NSInteger index = [_allSpecifiers indexOfObject:specifier];
			NSMutableArray *nestedEntries = [[_allSpecifiers subarrayWithRange:NSMakeRange(index + 1, [nestedEntryCount intValue])] mutableCopy];
			[self removeDisabledGroups:nestedEntries];
			if ([numValue boolValue]) {
				[self insertContiguousSpecifiers:nestedEntries afterSpecifier:specifier animated:YES];
			} else {
				[self removeContiguousSpecifiers:nestedEntries animated:YES];
			}
		}
	}
}
- (void)save {
    [self.view endEditing:YES];
}
- (void)testSecondPopup {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("xyz.itznebbs.batteryflow-reborn/secondpopuptest"), nil, nil, true);
}
@end