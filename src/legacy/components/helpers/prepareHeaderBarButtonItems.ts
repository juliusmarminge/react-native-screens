import { Image, processColor } from 'react-native';
import type { ImageResolvedAssetSource } from 'react-native';
import type {
  HeaderBarButtonItem,
  HeaderBarButtonItemWithMenu,
} from '../../types';

// Local nominal type so declaration emit doesn't resolve the RN alias down to
// the non-public `types_generated/.../AssetSourceResolver#ResolvedAssetSource`.
export interface ResolvedImageAsset extends ImageResolvedAssetSource {}

const prepareMenu = (
  menu: HeaderBarButtonItemWithMenu['menu'],
  index: number,
  placement: 'left' | 'right' | 'center' | 'toolbar',
  path: string = '',
): HeaderBarButtonItemWithMenu['menu'] => {
  return {
    ...menu,
    items: menu.items.map((menuItem, menuIndex) => {
      const currentPath = path ? `${path}.${menuIndex}` : `${menuIndex}`;
      const iconType = menuItem.icon?.type;
      const sfSymbolName =
        iconType === 'sfSymbol' ? menuItem.icon?.name : undefined;
      const xcassetName =
        iconType === 'xcasset' ? menuItem.icon?.name : undefined;

      let imageSource, templateSource;
      if (menuItem.icon?.type === 'imageSource') {
        imageSource = Image.resolveAssetSource(menuItem.icon.imageSource);
      } else if (menuItem.icon?.type === 'templateSource') {
        templateSource = Image.resolveAssetSource(menuItem.icon.templateSource);
      }

      if (menuItem.type === 'submenu') {
        return {
          ...menuItem,
          sfSymbolName,
          xcassetName,
          imageSource,
          templateSource,
          ...prepareMenu(menuItem, index, placement, currentPath),
        };
      }
      return {
        ...menuItem,
        sfSymbolName,
        xcassetName,
        imageSource,
        templateSource,
        menuId: `${currentPath}-${index}-${placement}`,
      };
    }),
  };
};

export const prepareHeaderBarButtonItems = (
  barButtonItems:
    | HeaderBarButtonItem[]
    | HeaderBarButtonItem
    | null
    | undefined,
  placement: 'left' | 'right' | 'center' | 'toolbar',
) => {
  const items = Array.isArray(barButtonItems)
    ? barButtonItems
    : barButtonItems && typeof barButtonItems === 'object' && 'type' in barButtonItems
      ? [barButtonItems]
      : undefined;

  return items?.map((item, index) => {
    if (item.type === 'spacing') {
      return item;
    }
    if (item.type === 'searchBarPlacement') {
      if (placement !== 'toolbar') {
        return null;
      }
      return {
        ...item,
        searchBarPlacement: true,
      };
    }
    if (item.type === 'searchField') {
      return {
        ...item,
        searchField: true,
      };
    }
    if (item.type === 'mailSearchToolbar') {
      return {
        ...item,
        mailSearchToolbar: true,
        filterMenu: item.filterMenu ? prepareMenu(item.filterMenu, index, placement, 'filter') : undefined,
        composeMenu: item.composeMenu ? prepareMenu(item.composeMenu, index, placement, 'compose') : undefined,
      };
    }
    let imageSource: ResolvedImageAsset | undefined,
      templateSource: ResolvedImageAsset | undefined;
    if (item.icon?.type === 'imageSource') {
      imageSource = Image.resolveAssetSource(item.icon.imageSource);
    } else if (item.icon?.type === 'templateSource') {
      templateSource = Image.resolveAssetSource(item.icon.templateSource);
    }

    const titleStyle = item.titleStyle
      ? { ...item.titleStyle, color: processColor(item.titleStyle.color) }
      : undefined;
    const tintColor = item.tintColor ? processColor(item.tintColor) : undefined;
    const badge = item.badge
      ? {
          ...item.badge,
          style: {
            ...item.badge.style,
            color: processColor(item.badge.style?.color),
            backgroundColor: processColor(item.badge.style?.backgroundColor),
          },
        }
      : undefined;
    const processedItem = {
      ...item,
      imageSource,
      templateSource,
      sfSymbolName: item.icon?.type === 'sfSymbol' ? item.icon.name : undefined,
      xcassetName: item.icon?.type === 'xcasset' ? item.icon.name : undefined,
      titleStyle,
      tintColor,
      badge,
    };
    if (item.type === 'button') {
      return {
        ...processedItem,
        buttonId: `${index}-${placement}`,
      };
    }
    if (item.type === 'menu') {
      return {
        ...processedItem,
        menu: prepareMenu(item.menu, index, placement),
      };
    }
    return null;
  }).filter(item => item !== null);
};
