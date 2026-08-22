-- Penn Access and Mobility
-- 003_private_storage.sql
-- Makes the job-files bucket private so photos are never publicly readable.
-- Run AFTER 001 and 002. Safe to re-run.
--
-- After running this, photos are only reachable through a signed link that
-- the app mints for a signed-in user and that expires in one hour.

-- Create the bucket if it does not exist, private either way.
insert into storage.buckets (id, name, public)
select 'job-files', 'job-files', false
where not exists (select 1 from storage.buckets where id = 'job-files');

-- Flip an existing public bucket to private.
update storage.buckets set public = false where id = 'job-files';

-- Only signed in users may read, upload, replace, or remove objects.
drop policy if exists p_jobfiles_select on storage.objects;
create policy p_jobfiles_select on storage.objects
  for select to authenticated
  using (bucket_id = 'job-files');

drop policy if exists p_jobfiles_insert on storage.objects;
create policy p_jobfiles_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'job-files');

drop policy if exists p_jobfiles_update on storage.objects;
create policy p_jobfiles_update on storage.objects
  for update to authenticated
  using (bucket_id = 'job-files');

drop policy if exists p_jobfiles_delete on storage.objects;
create policy p_jobfiles_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'job-files');

-- Explicitly make sure anonymous visitors have no path in.
drop policy if exists p_jobfiles_anon on storage.objects;
