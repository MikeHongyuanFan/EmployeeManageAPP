from django.core.management.base import BaseCommand
from leave_system.models import LeaveBalance

class Command(BaseCommand):
    help = 'Update leave hours based on day balances for existing records'

    def handle(self, *args, **options):
        balances = LeaveBalance.objects.all()
        updated_count = 0
        
        for balance in balances:
            # Update hour balances based on day balances
            balance.annual_leave_hours = balance.annual_leave_balance * 8
            balance.sick_leave_hours = balance.sick_leave_balance * 8
            balance.personal_leave_hours = balance.personal_leave_balance * 8
            balance.save()
            updated_count += 1
        
        self.stdout.write(self.style.SUCCESS(f'Successfully updated {updated_count} leave balance records'))
