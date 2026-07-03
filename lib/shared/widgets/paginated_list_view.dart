import 'package:abaad_flutter/shared/helpers/responsive_helper.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaginatedListView extends StatefulWidget {
  final ScrollController? scrollController;
  final Future<void> Function(int offset)? onPaginate;
  final int? totalSize;
  final int? offset;
  final Widget? productView;
  final bool enabledPagination;
  final bool reverse;

  const PaginatedListView({
    Key? key,
    this.scrollController,
    this.onPaginate,
    this.totalSize,
    this.offset,
    this.productView,
    this.enabledPagination = true,
    this.reverse = false,
  }) : super(key: key);

  @override
  State<PaginatedListView> createState() => _PaginatedListViewState();
}

class _PaginatedListViewState extends State<PaginatedListView> {
  bool _isLoading = false;

  void _onScroll() {
    if (!mounted) return;
    if (widget.enabledPagination != true) return;
    if (ResponsiveHelper.isDesktop(context)) return;

    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;

    final position = controller.position;
    if (position.pixels >= position.maxScrollExtent - 100) {
      _paginate();
    }
  }

  Future<void> _paginate() async {
    if (_isLoading) return;
    if (widget.onPaginate == null) return;

    final total = widget.totalSize ?? 0;
    final currentOffset = widget.offset ?? 1;
    final pageCount = (total / 10).ceil();

    if (currentOffset >= pageCount) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPaginate!(currentOffset + 1);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant PaginatedListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  Widget _buildFooter(BuildContext context, bool hasMore) {
    if (!hasMore && !_isLoading) return const SizedBox.shrink();

    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (ResponsiveHelper.isDesktop(context)) {
      return Center(
        child: InkWell(
          onTap: _paginate,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: Dimensions.PADDING_SIZE_SMALL,
              horizontal: Dimensions.PADDING_SIZE_LARGE,
            ),
            margin: EdgeInsets.only(top: Dimensions.PADDING_SIZE_SMALL),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              'view_more'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.totalSize ?? 0;
    final currentOffset = widget.offset ?? 1;
    final pageCount = (total / 10).ceil();
    final hasMore = currentOffset < pageCount;

    return ListView(
      controller: widget.scrollController,
      reverse: widget.reverse,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      children: [
        if (!widget.reverse) (widget.productView ?? const SizedBox.shrink()),
        _buildFooter(context, hasMore),
        if (widget.reverse) (widget.productView ?? const SizedBox.shrink()),
      ],
    );
  }
}
