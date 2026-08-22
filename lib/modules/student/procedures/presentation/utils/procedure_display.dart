import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Presentation helpers mapping the backend reliability model
/// (assuranceLevel / status) to Arabic labels, colours and icons.
class ProcedureDisplay {
  const ProcedureDisplay._();

  // ---- Assurance level (Verified / Attested / Flagged) ----

  static String assuranceLabel(String? level) {
    switch (level) {
      case 'Verified':
        return 'موثّق';
      case 'Attested':
        return 'مُصدّق';
      case 'Flagged':
        return 'مُعلّم للمراجعة';
      default:
        return 'قيد الحساب';
    }
  }

  static Color assuranceColor(String? level) {
    switch (level) {
      case 'Verified':
        return const Color(0xFF2E9E6B);
      case 'Attested':
        return const Color(0xFFD98C2B);
      case 'Flagged':
        return const Color(0xFFC1483F);
      default:
        return const Color(0xFF6B7280);
    }
  }

  static Color assuranceBg(String? level) {
    switch (level) {
      case 'Verified':
        return const Color(0xFFE7F5EE);
      case 'Attested':
        return const Color(0xFFFDF4E7);
      case 'Flagged':
        return const Color(0xFFFBECEB);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  static IconData assuranceIcon(String? level) {
    switch (level) {
      case 'Verified':
        return LucideIcons.shieldCheck;
      case 'Attested':
        return LucideIcons.badgeCheck;
      case 'Flagged':
        return LucideIcons.triangleAlert;
      default:
        return LucideIcons.clock;
    }
  }

  // ---- Status (Pending / Approved / Rejected / UnderInvestigation / Revoked) ----

  static String statusLabel(String? status) {
    switch (status) {
      case 'Approved':
        return 'معتمد';
      case 'Rejected':
        return 'مرفوض';
      case 'UnderInvestigation':
        return 'قيد التحقيق';
      case 'Revoked':
        return 'ملغى';
      case 'Pending':
      default:
        return 'قيد المراجعة';
    }
  }

  static Color statusColor(String? status) {
    switch (status) {
      case 'Approved':
        return const Color(0xFF047857);
      case 'Rejected':
        return const Color(0xFFB91C1C);
      case 'UnderInvestigation':
        return const Color(0xFF7C3AED);
      case 'Revoked':
        return const Color(0xFF4B5563);
      case 'Pending':
      default:
        return const Color(0xFFB45309);
    }
  }

  // ---- Integrity action reason ----

  static String integrityReasonLabel(String? reason) {
    switch (reason) {
      case 'Fabrication':
        return 'تلفيق بيانات';
      case 'PatientMismatch':
        return 'عدم تطابق بيانات المريض';
      case 'DuplicateEntry':
        return 'إدخال مُكرّر';
      case 'SupervisorDenial':
        return 'إنكار المشرف';
      case 'UnauthorizedApproval':
        return 'اعتماد غير مخوّل';
      case 'AdminError':
        return 'خطأ إداري';
      case 'Other':
      default:
        return 'سبب آخر';
    }
  }

  // ---- Anomaly flags ----

  static String flagLabel(String flag) {
    switch (flag) {
      case 'BULK_ENTRY':
        return 'إدخال مُجمّع';
      case 'BACKDATED':
        return 'تاريخ سابق';
      case 'DUPLICATE':
        return 'مُكرّر';
      default:
        return flag;
    }
  }
}
