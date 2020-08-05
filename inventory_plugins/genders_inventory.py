# import json
#
#

# if __name__ == "__main__" :
#     inventory_file = "/etc/genders"
#     myinventory = get_structured_inventory(inventory_file)
#     print(json.dumps(myinventory, indent=4))


from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import os

DOCUMENTATION = r'''
    name: genders_inventory
    plugin_type: inventory
    short_description: Returns Ansible inventory from genders file
    description: Returns Ansible inventory from genders file
    options:
      plugin:
          description: Name of the plugin
          required: true
          choices: ['genders_inventory']
      path_to_inventory:
        description: Directory location of the genders inventory
        required: true
      file:
        description: File name of the genders file
        required: true
'''

from ansible.plugins.inventory import BaseInventoryPlugin
from ansible.errors import AnsibleError, AnsibleParserError

class InventoryModule(BaseInventoryPlugin):
    NAME = 'genders_inventory'

    def verify_file(self, path):
        '''Return true/false if this is a
        valid file for this plugin to consume
        '''
        valid = False
        if super(InventoryModule, self).verify_file(path):
            #base class verifies that file exists
            #and is readable by current user
            if os.path.exists(path):
                valid = True
        return valid

    def parse(self, inventory, loader, path, cache):
        super(InventoryModule, self).parse(inventory, loader, path, cache)
        # Read the inventory YAML file
        self._read_config_data(path)
        try:
        # Store the options from the YAML file
            self.plugin = self.get_option('plugin')
            self.inv_dir = self.get_option('path_to_inventory')
            self.inv_file = self.get_option('file')
        except Exception as e:
            raise AnsibleParserError(
                'All correct options required: {}'.format(e))
        # Call our internal helper to populate the dynamic inventory
        self._populate()

    def _populate(self):
        '''Return the hosts and groups'''
        self.inventory_file = self.inv_dir + '/' + self.inv_file
        self.myinventory = self._get_structured_inventory(self.inventory_file)
        groups = []
        for data in self.myinventory.values():
            #data is a comma seperated list of groups
            for group in data.split(','):
                group = group.strip()
                if not group in groups:
                    groups.append(group)
                self.inventory.add_group(group)
            #Add the hosts to the groups

        for hostname,data in self.myinventory.items():
              for group in data.split(','):
                  group = group.strip()
                  self.inventory.add_host(host=hostname, group=group)


    def _get_structured_inventory(self,inventory_file):
        #Initialize a dict
        inventory_data = {}
        #Read the CSV and add it to the dictionary
        with open(inventory_file, 'r') as fh:
            lines = fh.readlines()
            for line in lines:
                splitLine = line.split(' ')
                host = splitLine[0]
                inventory_data[host] = splitLine[1]

        return inventory_data


