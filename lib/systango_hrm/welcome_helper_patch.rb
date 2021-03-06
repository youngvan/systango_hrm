module SystangoHrm
  module WelcomeHelperPatch
    def self.included(base)
       base.send(:include, InstanceMethods)
       base.class_eval do
         unloadable
       end
    end
    module InstanceMethods
      #TODO Are we using this Custom Field?
      def customfield
        CustomField.where(:name=> "Employee Code")
      end
      
      def leaves_of_current_user
        SystangoHrmEmployeeLeave.by_user_id_or_referral_id(User.current.id).order_by_created_desc
      end
      
      def pending_employee_leaves
        (SystangoHrmRequestReceiver.request_by_user_and_type(User.current, SystangoHrm::Constants::STATUS_PENDING).uniq.compact rescue []) 
      end
      
      def custom_value?
        CustomValue.all.blank?
      end
      
      def link_to_go_back
        link_to_function(l(:go_back), "history.back()")
      end

      def link_to_leave_dash_board
        link_to l(:label_leave_dashboard), systango_hrm_employee_leaves_path
      end  

      def leave_date_format(leave, date_type)
        date_format = (leave.is_half_day ? "%b %d, %y %H:%M" : "%b %d, %y")
        leave.send("leave_#{date_type}").strftime(date_format)
      end

      def apply_type(leave)
        leave.referral_id.nil? ? l(:label_self) : (leave.user ? leave.user.name : l(:label_refer))
      end

      def user_permission?(permission_for)
        (User.current.allowed_to_globally?(:"#{permission_for}", {}) or User.current.allowed_to_globally?(:hr_permissions, {}))
      end

      def user_has_any_systango_hrm_permission?
        ['apply_leave', 'view_leave_report_self', 'manage_leave_request', 'view_leave_report_hr_or_tl','add_compoff_details',
         'show_subordinate_and_its_teamlead', 'add_teamlead_subordinates_details', 'add_designation_wise_entitled_leaves',
         'add_employee_leave_details', 'add_subject_for_leave', 'add_holiday_calendar', 'hr_permissions'].each do |permission_for|
          return true if user_permission?(permission_for)
        end
        false
      end

    end
  end
end