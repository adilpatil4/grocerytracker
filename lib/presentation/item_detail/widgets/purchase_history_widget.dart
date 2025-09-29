import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PurchaseHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> purchaseHistory;

  const PurchaseHistoryWidget({
    Key? key,
    required this.purchaseHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (purchaseHistory.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'history',
                    size: 24,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Purchase History',
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'receipt_long',
                      size: 32,
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.4),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No purchase history available',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'history',
                  size: 24,
                  color: AppTheme.lightTheme.primaryColor,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Purchase History',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Price trend chart
            Container(
              height: 20.h,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 10.w,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toInt()}',
                            style: AppTheme.lightTheme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 4.h,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < purchaseHistory.length) {
                            final date = DateTime.parse(
                                purchaseHistory[index]['date'] as String);
                            return Text(
                              '${date.month}/${date.day}',
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: purchaseHistory.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          (entry.value['price'] as double),
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppTheme.lightTheme.primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppTheme.lightTheme.primaryColor,
                            strokeWidth: 2,
                            strokeColor:
                                AppTheme.lightTheme.colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 2.h),
            Text(
              'Recent Purchases',
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
            SizedBox(height: 1.h),

            // Purchase history list
            ...purchaseHistory
                .take(3)
                .map((purchase) => _buildPurchaseItem(purchase))
                .toList(),

            if (purchaseHistory.length > 3) ...[
              SizedBox(height: 1.h),
              Center(
                child: TextButton(
                  onPressed: () {
                    // Show all purchase history
                  },
                  child: Text(
                    'View All (${purchaseHistory.length} purchases)',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseItem(Map<String, dynamic> purchase) {
    final date = DateTime.parse(purchase['date'] as String);
    final formattedDate =
        '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomIconWidget(
              iconName: 'receipt',
              size: 20,
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      purchase['store'] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '\$${(purchase['price'] as double).toStringAsFixed(2)}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      'Qty: ${purchase['quantity']}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
