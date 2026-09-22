import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../models/boyfriend_preset.dart';

/// 角色头像：`preset:` 前缀走内置图片资源，其余按网络图片处理，空值回退为图标。
/// [previewable] 为 true 且有头像时，点击进入大图预览；内置预设头像附带
/// 同 key 的 3D 模型时，可在预览中切换到 3D 查看（可旋转缩放）。
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({
    super.key,
    this.avatar,
    this.size = 40,
    this.previewable = false,
  });

  final String? avatar;
  final double size;
  final bool previewable;

  /// 大图预览：内置资源用 Image.asset，外链用 Image.network；
  /// 预设头像存在对应 `model:bf_xxx` 模型时支持切换 3D 视图。
  static void showPreview(BuildContext context, String avatar) {
    if (avatar.isEmpty) return;
    final image = BoyfriendPreset.isPreset(avatar)
        ? Image.asset(BoyfriendPreset.assetOf(avatar), fit: BoxFit.contain)
        : Image.network(
            avatar,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: 96,
            ),
          );
    final model = BoyfriendPreset.modelFor(avatar);
    var show3D = false;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Stack(
                  children: [
                    Center(
                      child: show3D && model != null
                          ? ModelViewer(
                              src: BoyfriendPreset.modelAssetOf(model),
                              alt: '3D 模型预览',
                              autoRotate: true,
                              cameraControls: true,
                              backgroundColor: Colors.transparent,
                            )
                          : InteractiveViewer(maxScale: 4, child: image),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    if (model != null)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: FilledButton.tonalIcon(
                            icon: Icon(
                              show3D
                                  ? Icons.image_outlined
                                  : Icons.view_in_ar_outlined,
                            ),
                            label: Text(show3D ? '查看图片' : '查看 3D'),
                            onPressed: () => setState(() => show3D = !show3D),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = avatar;
    Widget child;
    if (value != null && BoyfriendPreset.isPreset(value)) {
      child = ClipOval(
        child: Image.asset(
          BoyfriendPreset.assetOf(value),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      child = CircleAvatar(
        radius: size / 2,
        backgroundImage: value != null && value.isNotEmpty
            ? NetworkImage(value)
            : null,
        child: value == null || value.isEmpty
            ? Icon(Icons.person_outline, size: size * 0.55)
            : null,
      );
    }
    if (previewable && value != null && value.isNotEmpty) {
      child = GestureDetector(
        onTap: () => showPreview(context, value),
        child: child,
      );
    }
    return SizedBox(width: size, height: size, child: child);
  }
}
