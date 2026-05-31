import os

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                lines = f.readlines()
            
            changed = False
            for i, line in enumerate(lines):
                if 'models/report_model.dart' in line or 'services/report_service.dart' in line:
                    if filepath.startswith('lib/core/'):
                        if 'import \'../../models/report_model.dart\';' in line:
                            lines[i] = line.replace('../../models/', '../models/')
                            changed = True
                        elif 'import \'../../services/report_service.dart\';' in line:
                            lines[i] = line.replace('../../services/', '')
                            changed = True
                        elif 'import \'../models/report_model.dart\';' in line:
                            # already correct inside core/services
                            pass
                    else:
                        if 'import \'../models/report_model.dart\';' in line:
                            lines[i] = line.replace('../models/', '../core/models/')
                            changed = True
                        elif 'import \'../services/report_service.dart\';' in line:
                            lines[i] = line.replace('../services/', '../core/services/')
                            changed = True
                        elif 'import \'../../models/report_model.dart\';' in line:
                            lines[i] = line.replace('../../models/', '../../core/models/')
                            changed = True
                        elif 'import \'../../services/report_service.dart\';' in line:
                            lines[i] = line.replace('../../services/', '../../core/services/')
                            changed = True

            if changed:
                with open(filepath, 'w') as f:
                    f.writelines(lines)
                print(f"Updated {filepath}")
